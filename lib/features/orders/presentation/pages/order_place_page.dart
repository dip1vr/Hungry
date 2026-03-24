import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:hungry/features/orders/presentation/controllers/food_controller.dart';
import 'package:hungry/shared/widgets/optimized_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hungry/features/location/google_map_place_picker.dart';

// Brand Colors
const kPrimaryColor = Color(0xFFFF5200);
const kBgColor = Color(0xFFF4F6F8);

class PlaceOrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String customerId;

  const PlaceOrderPage({
    super.key,
    required this.cartItems,
    required this.customerId,
  });

  @override
  State<PlaceOrderPage> createState() => _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  final FoodController controller = Get.find<FoodController>();
  bool placingOrder = false;
  int _selectedPaymentMethod = 0; // 0: COD, 1: UPI, 2: Card
  bool _fetchingLocation = false;
  double? _latitude;
  double? _longitude;

  final TextEditingController _addressController = TextEditingController(
    text: "123, Main Street, Springfield, IL 62704",
  );

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Permission Denied", "Location permission is required.");
          setState(() => _fetchingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "Permission Denied",
          "Location permission is permanently denied.",
        );
        setState(() => _fetchingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Store coordinates
      _latitude = position.latitude;
      _longitude = position.longitude;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          List<String> parts = [];

          if (place.street != null && place.street!.isNotEmpty) {
            parts.add(place.street!);
          }
          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            parts.add(place.subLocality!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            parts.add(place.locality!);
          }
          if (place.postalCode != null && place.postalCode!.isNotEmpty) {
            parts.add(place.postalCode!);
          }
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            parts.add(place.administrativeArea!);
          }

          // Remove duplicates and join
          String address = parts.toSet().join(", ");

          setState(() {
            _addressController.text = address.isNotEmpty
                ? address
                : "Unknown Address";
          });
        }
      } catch (e) {
        debugPrint("Geocoding failed: $e");
        setState(() {
          // Fallback to coordinates but cleaner message
          _addressController.text =
              "Location Found (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})";
        });
        Get.snackbar(
          "Address Fetch Failed",
          "We found you, but couldn't get the address details. Please type it manually if needed.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to get location: $e");
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Delivery Address"),
                      TextButton.icon(
                        onPressed: _fetchingLocation ? null : _fetchLocation,
                        icon: _fetchingLocation
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location, size: 16),
                        label: const Text(
                          "Fetch Location",
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildAddressCard(),

                  const SizedBox(height: 24),

                  // items preview (horizontal scroll)
                  _buildSectionTitle("Order Summary"),
                  const SizedBox(height: 12),
                  _buildItemsPreview(),

                  const SizedBox(height: 24),

                  // Payment Method
                  _buildSectionTitle("Payment Method"),
                  const SizedBox(height: 12),
                  _buildPaymentMethods(),

                  const SizedBox(height: 24),

                  // Bill Details
                  _buildSectionTitle("Bill Details"),
                  const SizedBox(height: 12),
                  _buildBillSummary(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Pay Button
          _buildBottomPayBar(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Location",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _addressController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: "Enter delivery address",
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Get.to(() => const GoogleMapPlacePicker());
            },
            child: const Text(
              "CHANGE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsPreview() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.cartItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          return Container(
            width: 250,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: OptimizedNetworkImage(
                    imageUrl:
                        item['imageUrl'] ?? "https://i.pravatar.cc/300?img=12",
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${item['quantity']} x ₹${item['price']}",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPaymentOption(0, "Cash on Delivery", Icons.money),
          const Divider(height: 1, indent: 60),
          _buildPaymentOption(1, "UPI / Wallet", Icons.qr_code),
          const Divider(height: 1, indent: 60),
          _buildPaymentOption(2, "Credit / Debit Card", Icons.credit_card),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int value, String title, IconData icon) {
    bool isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? kPrimaryColor : Colors.grey),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: kPrimaryColor)
            else
              const Icon(Icons.circle_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Unified Vendor Grouping
          Builder(
            builder: (context) {
              final offer = controller.appliedOfferData.value;
              final vendorId = offer != null ? offer['vendorId'] : null;

              if (vendorId != null) {
                // Grouping Logic
                final vendorItems = controller.cartItems
                    .where((i) => i['vendorId'] == vendorId)
                    .toList();
                final otherItems = controller.cartItems
                    .where((i) => i['vendorId'] != vendorId)
                    .toList();

                final bool isItemSpecific = offer!['isItemSpecific'] == true;
                final String couponCode =
                    offer['code'] ?? controller.appliedCouponCode.value;

                // Calculate Vendor Subtotal (Gross)
                final double vendorGrossTotal = vendorItems.fold(
                  0.0,
                  (sum, item) =>
                      sum + ((item['price'] ?? 0) * (item['quantity'] ?? 1)),
                );
                final double vendorNetTotal =
                    vendorGrossTotal - controller.discountAmount.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "OFFER APPLIED ON RESTAURANT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Vendor Items
                          ...vendorItems.map((item) {
                            final bool isTargetItem =
                                isItemSpecific &&
                                item['title'] == offer['sourceItemTitle'];

                            return Column(
                              children: [
                                _buildBreakdownItemRow(item),
                                // Item Specific Discount
                                if (isTargetItem)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.subdirectory_arrow_right,
                                          size: 14,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            "Coin ($couponCode) applied on this item",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "- ₹${controller.discountAmount.value.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),

                          // Restaurant Level Discount (if not item specific)
                          if (!isItemSpecific)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Restaurant Coupon ($couponCode)",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "- ₹${controller.discountAmount.value.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),

                          // Restaurant Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Restaurant Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "₹${vendorNetTotal.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (otherItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        "OTHER ITEMS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...otherItems.map((item) => _buildBreakdownItemRow(item)),
                    ],
                  ],
                );
              } else {
                // Standard Flat List (No vendor info or global coupon)
                return Column(
                  children: controller.cartItems
                      .map((item) => _buildBreakdownItemRow(item))
                      .toList(),
                );
              }
            },
          ),

          if (controller.discountAmount.value > 0) ...[
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                String label = "Discount";
                final offer = controller.appliedOfferData.value;
                if (offer != null) {
                  if (offer['isItemSpecific'] == true) {
                    label = "Discount (on ${offer['sourceItemTitle']})";
                  } else if (offer['vendorId'] != null) {
                    label = "Restaurant Discount";
                  }
                }

                return _buildBillRow(
                  label,
                  "-₹${controller.discountAmount.value.toStringAsFixed(2)}",
                  color: Colors.green,
                );
              },
            ),
            const SizedBox(height: 10),
            _buildBillRow(
              "Subtotal",
              "₹${(controller.totalPrice - controller.discountAmount.value).toStringAsFixed(2)}",
              isBold: true,
              fontSize: 14,
            ),
          ],

          const SizedBox(height: 10),
          _buildBillRow(
            "Delivery Fee",
            controller.isFreeDelivery.value
                ? "FREE"
                : "₹${controller.deliveryFee.toStringAsFixed(2)}",
            color: controller.isFreeDelivery.value
                ? Colors.green
                : Colors.black87,
            isStrikethrough: controller
                .isFreeDelivery
                .value, // Add strikethrough capability if needed, or just show FREE
            originalValue: controller.isFreeDelivery.value ? "₹40.00" : null,
          ),

          const SizedBox(height: 10),
          _buildBillRow(
            "Taxes & Charges",
            "₹${controller.taxAmount.toStringAsFixed(2)}",
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildBillRow(
            "To Pay",
            "₹${controller.grandTotal.toStringAsFixed(2)}",
            isBold: true,
            fontSize: 18,
            color: kPrimaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 14,
    Color? color,
    bool isStrikethrough = false,
    String? originalValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Row(
          children: [
            if (isStrikethrough && originalValue != null) ...[
              Text(
                originalValue,
                style: TextStyle(
                  fontSize: fontSize - 2,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownItemRow(Map<String, dynamic> item) {
    final String name = item['title'] ?? 'Item';
    final int qty = item['quantity'] ?? 1;
    final double price = (item['price'] ?? 0).toDouble();
    final double subtotal = price * qty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$name x $qty",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "₹${subtotal.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPayBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              elevation: 8,
              shadowColor: kPrimaryColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: placingOrder ? null : placeOrder,
            child: placingOrder
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "PAY NOW",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "₹${controller.grandTotal.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Place order for each vendor
  Future<void> placeOrder() async {
    if (widget.cartItems.isEmpty) return;
    if (_addressController.text.trim().isEmpty) {
      Get.snackbar(
        "Address Required",
        "Please enter a delivery address.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    setState(() => placingOrder = true);

    try {
      // Fetch User Details to save with order
      String customerName = "Unknown";
      String customerPhone = "Unknown";
      String customerProfileImage = "";

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.customerId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          customerName = data['name'] ?? "Unknown";
          customerPhone = data['phone'] ?? "Unknown";
          customerProfileImage = data['profileImage'] ?? "";
        }
      } catch (e) {
        debugPrint("Error fetching user details for order: $e");
      }

      final itemsByVendor = groupByVendor();
      bool isFirstVendor = true; // Flag to apply delivery fee only once

      for (var vendorId in itemsByVendor.keys) {
        var vendorItems = itemsByVendor[vendorId]!;

        // 1. Calculate Vendor Subtotal
        double vendorSubTotal = vendorItems.fold(
          0,
          (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1)),
        );

        // 2. Calculate Vendor Tax
        double vendorTax = vendorSubTotal * 0.05;

        // 3. Determine Delivery Fee (App Revenue)
        // Apply full delivery fee to the FIRST order only, so the customer is charged once total.
        // We do NOT split it.
        double currentDeliveryFee = 0.0;
        if (isFirstVendor) {
          currentDeliveryFee = controller.deliveryFee;
          isFirstVendor = false;
        }

        // 4. Determine Vendor Discount & Coupon
        double vendorDiscount = 0.0;
        String? vendorCouponCode = "";

        final appliedOffer = controller.appliedOfferData.value;
        if (appliedOffer != null) {
          final String? offerVendorId = appliedOffer['vendorId'];

          if (offerVendorId != null) {
            // Vendor-Specific Coupon
            if (offerVendorId == vendorId) {
              vendorDiscount = controller.discountAmount.value;
              vendorCouponCode = controller.appliedCouponCode.value;
            }
          } else {
            // Global Coupon: Split proportional to subtotal
            if (controller.totalPrice > 0) {
              double fraction = vendorSubTotal / controller.totalPrice;
              vendorDiscount = controller.discountAmount.value * fraction;
              vendorCouponCode = controller.appliedCouponCode.value;
            }
          }
        } else if (controller.appliedCouponCode.value == "shyam") {
          vendorCouponCode = "shyam";
        }

        // 5. Calculate Totals

        // A. Customer Total (EXCLUDES Delivery Fee now, stored separately)
        double customerTotalAmount =
            vendorSubTotal + vendorTax - vendorDiscount;
        if (customerTotalAmount < 0) customerTotalAmount = 0;

        // B. Vendor View Total (EXCLUDES Delivery Fee - "App ka hai")
        // Vendor gets Subtotal + Tax - Discount.
        double vendorViewTotal = vendorSubTotal + vendorTax - vendorDiscount;
        if (vendorViewTotal < 0) vendorViewTotal = 0;

        final orderRef = FirebaseFirestore.instance.collection('orders').doc();

        // Main Order Record (Source of Truth for App/Customer)
        await orderRef.set({
          'userId': widget.customerId,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'customerProfileImage': customerProfileImage,
          'vendorId': vendorId,
          'status': 'pending',
          'totalAmount': customerTotalAmount, // DOES NOT INCLUDE DELIVERY FEE
          'amountToVendor':
              vendorViewTotal, // PURELY Vendor's share (Sub+Tax-Disc)
          'subTotal': vendorSubTotal,
          'tax': vendorTax,
          'deliveryFee': currentDeliveryFee, // To App
          'discount': vendorDiscount,
          'coupon': vendorCouponCode,
          'deliveryAddress': _addressController.text.trim(),
          'latitude': _latitude,
          'longitude': _longitude,
          'paymentMethod': _selectedPaymentMethod == 0
              ? 'COD'
              : (_selectedPaymentMethod == 1 ? 'UPI' : 'Card'),
          'createdAt': FieldValue.serverTimestamp(),
          'items': vendorItems
              .map(
                (item) => {
                  'title': item['title'],
                  'price': item['price'],
                  'quantity': item['quantity'] ?? 1,
                  'imageUrl': item['imageUrl'],
                },
              )
              .toList(),
        });

        // Save order into user's order history
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.customerId)
            .collection('orders')
            .doc(orderRef.id)
            .set({
              'orderId': orderRef.id,
              'vendorId': vendorId,
              'status': 'pending',
              'totalAmount': customerTotalAmount, // User sees what they paid
              'subTotal': vendorSubTotal,
              'discount': vendorDiscount,
              'deliveryAddress': _addressController.text.trim(),
              'latitude': _latitude,
              'longitude': _longitude,
              'paymentMethod': _selectedPaymentMethod == 0
                  ? 'COD'
                  : (_selectedPaymentMethod == 1 ? 'UPI' : 'Card'),
              'createdAt': FieldValue.serverTimestamp(),
              'items': vendorItems,
            });

        // Add items collection
        for (var item in vendorItems) {
          await orderRef.collection('items').add({
            'title': item['title'],
            'price': item['price'],
            'quantity': item['quantity'] ?? 1,
            'imageUrl': item['imageUrl'],
          });
        }

        // Vendor Notification Record
        // CRITICAL: We pass 'vendorViewTotal' (Excluding Delivery)
        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(vendorId)
            .collection('orders')
            .doc(orderRef.id)
            .set({
              'orderId': orderRef.id,
              'status': 'pending',
              'customerId': widget.customerId,
              'customerName': customerName,
              'customerPhone': customerPhone,
              'customerProfileImage': customerProfileImage,
              'total': vendorViewTotal, // Vendor sees their earnings ONLY
              'subTotal':
                  vendorSubTotal - vendorDiscount, // Net Subtotal (Matches UI)
              'tax': vendorTax, // Explicitly show tax
              'discount': vendorDiscount,
              'items': vendorItems
                  .map(
                    (e) => {
                      'title': e['title'],
                      'price': e['price'],
                      'quantity': e['quantity'] ?? 1,
                    },
                  )
                  .toList(),
              'timestamp': FieldValue.serverTimestamp(),
              'newOrder': true,
              'deliveryAddress': _addressController.text.trim(),
              'latitude': _latitude,
              'longitude': _longitude,
            });
      }

      // Success!
      if (mounted) {
        Get.defaultDialog(
          title: "Order Placed!",
          titleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          middleText: "Your delicious food is on its way.",
          backgroundColor: Colors.white,
          confirm: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Close Checkout
              Get.back(); // Close Cart
              controller.cartItems.clear(); // Clear cart
              controller.removeCoupon();
            },
            child: const Text("Awesome", style: TextStyle(color: Colors.white)),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to place order: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => placingOrder = false);
    }
  }

  Map<String, List<Map<String, dynamic>>> groupByVendor() {
    Map<String, List<Map<String, dynamic>>> itemsByVendor = {};
    for (var item in widget.cartItems) {
      String vendorId = item['vendorId'];
      if (!itemsByVendor.containsKey(vendorId)) itemsByVendor[vendorId] = [];
      itemsByVendor[vendorId]!.add(item);
    }
    return itemsByVendor;
  }
}
