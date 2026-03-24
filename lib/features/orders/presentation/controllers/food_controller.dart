import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hungry/core/services/user_activity_service.dart'; // Import UserActivityService
import 'package:get/get.dart';

class FoodController extends GetxController {
  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  // Coupon State
  RxString appliedCouponCode = ''.obs;
  RxDouble discountAmount = 0.0.obs;
  RxBool isFreeDelivery = false.obs;
  Rxn<Map<String, dynamic>> appliedOfferData = Rxn<Map<String, dynamic>>();

  // Suggested Offers
  RxList<Map<String, dynamic>> suggestedOffers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Re-fetch suggestions whenever cart changes
    ever(cartItems, (_) => fetchSuggestedOffers());
    fetchSuggestedOffers();
  }

  void addToCart(Map<String, dynamic> foodItem) {
    final existingItemIndex = cartItems.indexWhere(
      (item) =>
          item["title"] == foodItem["title"] &&
          item["vendorId"] == foodItem["vendorId"],
    );
    if (existingItemIndex != -1) {
      cartItems[existingItemIndex]["quantity"]++;
      cartItems.refresh();
      // Log add to cart action (quantity increase)
      if (Get.isRegistered<UserActivityService>()) {
        UserActivityService.to.logActivity(
          'add_to_cart',
          details: foodItem["title"],
        );
      }
    } else {
      cartItems.add(foodItem);
      // Log add to cart action (new item)
      if (Get.isRegistered<UserActivityService>()) {
        UserActivityService.to.logActivity(
          'add_to_cart',
          details: foodItem["title"],
        );
      }
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      cartItems[index]["quantity"] = newQuantity;
      cartItems.refresh();
      // Re-validate coupon on quantity change
      if (appliedCouponCode.isNotEmpty) {
        validateCoupon(appliedCouponCode.value);
      }
    } else {
      cartItems.removeAt(index);
      if (cartItems.isEmpty) {
        removeCoupon();
      } else if (appliedCouponCode.isNotEmpty) {
        validateCoupon(appliedCouponCode.value);
      }
    }
  }

  void fetchSuggestedOffers() async {
    if (cartItems.isEmpty) {
      suggestedOffers.clear();
      return;
    }

    final List<Map<String, dynamic>> allOffers = [];
    final Set<String> seenCodes = {};

    // 1. Collect Item-Specific Offers FIRST (Higher Priority)
    for (var item in cartItems) {
      final rawOffer = item['itemOffer'] ?? item['offer'];
      if (rawOffer != null && rawOffer is Map) {
        final Map<String, dynamic> offer = Map<String, dynamic>.from(rawOffer);
        if (_isOfferValid(offer)) {
          offer['vendorId'] = item['vendorId'];
          offer['isItemSpecific'] = true;
          offer['sourceItemTitle'] = item['title'];

          final String title = (offer['title'] ?? offer['name'] ?? 'OFFER')
              .toString();
          final String code = (offer['code'] ?? offer['couponCode'] ?? title)
              .toString();

          final String normalizedCode = code.trim().toLowerCase();
          if (normalizedCode.isNotEmpty &&
              !seenCodes.contains(normalizedCode)) {
            offer['title'] = title;
            offer['code'] = code;
            allOffers.add(offer);
            seenCodes.add(normalizedCode);
          }
        }
      }
    }

    // 2. Collect Restaurant-Level Offers
    final vendorIds = cartItems
        .map((item) => item['vendorId'] as String?)
        .where((id) => id != null)
        .toSet();

    for (var vId in vendorIds) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(vId)
            .collection('offers')
            .where('isActive', isEqualTo: true)
            .get();

        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (_isOfferValid(data)) {
            data['vendorId'] = vId;
            data['isItemSpecific'] = false;
            final String title = (data['title'] ?? data['name'] ?? 'OFFER')
                .toString();
            final String code = (data['code'] ?? data['couponCode'] ?? title)
                .toString();

            final String normalizedCode = code.trim().toLowerCase();
            if (normalizedCode.isNotEmpty &&
                !seenCodes.contains(normalizedCode)) {
              data['title'] = title;
              data['code'] = code;
              allOffers.add(data);
              seenCodes.add(normalizedCode);
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching suggested offers for $vId: $e");
      }
    }

    suggestedOffers.value = allOffers;
  }

  bool _isOfferValid(Map<String, dynamic> offer) {
    // 1. Check Active Status
    final bool isActive =
        offer['isActive'] == true ||
        offer['isActive'] == 'true' ||
        offer['isActive'] == 1;
    if (!isActive) return false;

    // 2. Check Dates
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (offer['startDate'] is Timestamp) {
      start = (offer['startDate'] as Timestamp).toDate();
    }
    if (offer['endDate'] is Timestamp) {
      end = (offer['endDate'] as Timestamp).toDate();
    }

    if (start != null && end != null) {
      return now.isAfter(start) && now.isBefore(end);
    }
    return true; // Valid if no dates specified
  }

  double get totalPrice => cartItems.fold(
    0,
    (sum, item) => sum + (item["price"] * item["quantity"]),
  );

  double get deliveryFee => isFreeDelivery.value ? 0.0 : 40.0;

  double get taxAmount => totalPrice * 0.05; // 5% Tax

  double get grandTotal {
    double total = totalPrice + taxAmount + deliveryFee - discountAmount.value;
    return total > 0 ? total : 0.0;
  }

  String applyCoupon(String code) {
    if (cartItems.isEmpty) return "Cart is empty";

    String normalizedCode = code.trim().toLowerCase();

    // 1. Check Hardcoded/Global Coupons
    if (normalizedCode == "shyam") {
      isFreeDelivery.value = true;
      discountAmount.value = 0.0;
      appliedCouponCode.value = "shyam";
      appliedOfferData.value = null;
      return "Success";
    } else if (normalizedCode == "hungry50") {
      if (totalPrice > 200) {
        discountAmount.value = 50.0;
        isFreeDelivery.value = false;
        appliedCouponCode.value = "hungry50";
        appliedOfferData.value = null;
        return "Success";
      } else {
        return "Order total must be above ₹200";
      }
    }

    // 2. Check Dynamic Suggested Offers
    final matchingOffer = suggestedOffers.firstWhereOrNull((off) {
      final title = (off['title'] ?? '').toString().toLowerCase();
      final code = (off['code'] ?? off['couponCode'] ?? '')
          .toString()
          .toLowerCase();
      return title == normalizedCode || code == normalizedCode;
    });

    if (matchingOffer != null) {
      final vendorId = matchingOffer['vendorId'];
      double relevantSubtotal = totalPrice;

      // Calculate subtotal for this specific vendor or item
      if (vendorId != null) {
        final bool isItemSpecific = matchingOffer['isItemSpecific'] == true;
        final String? itemTitle = matchingOffer['sourceItemTitle'];

        relevantSubtotal = cartItems
            .where((item) {
              bool matchesGroup = item['vendorId'] == vendorId;
              if (isItemSpecific && itemTitle != null) {
                matchesGroup = matchesGroup && item['title'] == itemTitle;
              }
              return matchesGroup;
            })
            .fold(0.0, (sum, item) => sum + (item["price"] * item["quantity"]));
      }

      final minAmt =
          matchingOffer['minOrderValue'] ??
          matchingOffer['minAmount'] ??
          matchingOffer['minOrder'] ??
          0;

      if (relevantSubtotal < (minAmt as num)) {
        return vendorId != null
            ? "Add ₹${(minAmt - relevantSubtotal).toStringAsFixed(0)} more from this restaurant to apply"
            : "Minimum order of ₹$minAmt required";
      }

      final val = matchingOffer['discountValue'];
      final isPercent =
          matchingOffer['discountType'] == 'percentage' ||
          matchingOffer['discountType'] == 'percent';

      if (isPercent) {
        discountAmount.value = (relevantSubtotal * (val / 100)).toDouble();
      } else {
        discountAmount.value = (val as num).toDouble();
      }

      isFreeDelivery.value = false;
      appliedCouponCode.value =
          matchingOffer['code'] ?? matchingOffer['title'] ?? "OFFER";
      appliedOfferData.value = matchingOffer;
      return "Success";
    }

    return "Invalid Coupon Code";
  }

  void validateCoupon(String code) {
    if (code.isEmpty) return;

    // 1. Basic re-validation for hungry50
    if (code.toLowerCase() == "hungry50" && totalPrice <= 200) {
      removeCoupon();
      return;
    }

    // 2. Dynamic offer re-validation
    final matchingOffer = suggestedOffers.firstWhereOrNull((off) {
      final title = (off['title'] ?? '').toString().toLowerCase();
      final oCode = (off['code'] ?? off['couponCode'] ?? '')
          .toString()
          .toLowerCase();
      return title == code.toLowerCase() || oCode == code.toLowerCase();
    });

    if (matchingOffer != null) {
      final vendorId = matchingOffer['vendorId'];
      double relevantSubtotal = totalPrice;

      if (vendorId != null) {
        final bool isItemSpecific = matchingOffer['isItemSpecific'] == true;
        final String? itemTitle = matchingOffer['sourceItemTitle'];

        relevantSubtotal = cartItems
            .where((item) {
              bool matchesGroup = item['vendorId'] == vendorId;
              if (isItemSpecific && itemTitle != null) {
                matchesGroup = matchesGroup && item['title'] == itemTitle;
              }
              return matchesGroup;
            })
            .fold(0.0, (sum, item) => sum + (item["price"] * item["quantity"]));
      }

      final minAmt =
          matchingOffer['minOrderValue'] ??
          matchingOffer['minAmount'] ??
          matchingOffer['minOrder'] ??
          0;
      if (relevantSubtotal < (minAmt as num)) {
        removeCoupon();
      } else {
        // Re-calculate discount in case relevantSubtotal changed
        final val = matchingOffer['discountValue'];
        final isPercent =
            matchingOffer['discountType'] == 'percentage' ||
            matchingOffer['discountType'] == 'percent';

        if (isPercent) {
          discountAmount.value = (relevantSubtotal * (val / 100)).toDouble();
        } else {
          discountAmount.value = (val as num).toDouble();
        }
        appliedOfferData.value = matchingOffer;
      }
    }
  }

  void removeCoupon() {
    appliedCouponCode.value = '';
    discountAmount.value = 0.0;
    isFreeDelivery.value = false;
    appliedOfferData.value = null;
  }
}
