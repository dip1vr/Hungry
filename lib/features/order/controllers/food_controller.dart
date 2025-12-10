import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FoodController extends GetxController {
  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  // Coupon State
  RxString appliedCouponCode = ''.obs;
  RxDouble discountAmount = 0.0.obs;
  RxBool isFreeDelivery = false.obs;

  void addToCart(Map<String, dynamic> foodItem) {
    final existingItemIndex = cartItems.indexWhere(
      (item) =>
          item["title"] == foodItem["title"] &&
          item["vendorId"] == foodItem["vendorId"],
    );
    if (existingItemIndex != -1) {
      cartItems[existingItemIndex]["quantity"]++;
      cartItems.refresh();
    } else {
      cartItems.add(foodItem);
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      cartItems[index]["quantity"] = newQuantity;
      cartItems.refresh();
      // Re-validate coupon on quantity change (in case total drops below threshold)
      if (appliedCouponCode.isNotEmpty) {
        validateCoupon(appliedCouponCode.value);
      }
    } else {
      cartItems.removeAt(index);
      if (cartItems.isEmpty) {
        removeCoupon(); // Clear coupon if cart is empty
      } else if (appliedCouponCode.isNotEmpty) {
        validateCoupon(appliedCouponCode.value);
      }
    }
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
    if (cartItems.isEmpty) {
      return "Cart is empty";
    }

    code = code
        .trim(); // Case sensitive as per user request ("shyam", "hungry50")? User typed lowercase in prompt.
    // Let's make it case-insensitive for better UX, or strict?
    // User wrote: "shyam" and "hungry50". I will handle case-insensitive for usability.

    String normalizedCode = code.toLowerCase();

    if (normalizedCode == "shyam") {
      isFreeDelivery.value = true;
      discountAmount.value = 0.0;
      appliedCouponCode.value = "shyam";
      return "Success";
    } else if (normalizedCode == "hungry50") {
      if (totalPrice > 200) {
        discountAmount.value = 50.0;
        isFreeDelivery.value = false;
        appliedCouponCode.value = "hungry50";
        return "Success";
      } else {
        return "Order total must be above ₹200";
      }
    } else {
      return "Invalid Coupon Code";
    }
  }

  // Helper to re-validate current coupon when cart changes
  void validateCoupon(String code) {
    if (code == "hungry50" && totalPrice <= 200) {
      removeCoupon();
      Get.snackbar(
        "Coupon Removed",
        "Cart total dropped below ₹200",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void removeCoupon() {
    appliedCouponCode.value = '';
    discountAmount.value = 0.0;
    isFreeDelivery.value = false;
  }
}
