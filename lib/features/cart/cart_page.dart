import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hungry/common/widgets/optimized_network_image.dart';
import 'package:hungry/features/order/controllers/food_controller.dart';
import 'package:hungry/features/order/order_place_page.dart';

// Brand Colors
const kPrimaryColor = Color(0xFFFF5200);
const kBgColor = Color(0xFFF4F6F8);

class CartPage extends StatelessWidget {
  CartPage({super.key});

  final FoodController controller = Get.find<FoodController>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _couponController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
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
      body: Obx(
        () => controller.cartItems.isEmpty
            ? _buildEmptyCart()
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Items Added"),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.cartItems.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = controller.cartItems[index];
                              return _buildCartItem(item, index);
                            },
                          ),
                          const SizedBox(height: 30),
                          _buildSectionTitle("Offers & Benefits"),
                          const SizedBox(height: 12),
                          _buildCouponSection(),

                          const SizedBox(height: 30),
                          _buildSectionTitle("Bill Details"),
                          const SizedBox(height: 12),
                          _buildBillSummary(),
                          const SizedBox(height: 100), // Space for bottom bar
                        ],
                      ),
                    ),
                  ),
                  _buildBottomCheckoutBar(),
                ],
              ),
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

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: kPrimaryColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Your Cart is Empty",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Looks like you haven't added\nany food yet.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: kPrimaryColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            onPressed: () => Get.back(),
            child: Text(
              "Start Ordering",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: OptimizedNetworkImage(
                imageUrl:
                    item["imageUrl"] ??
                    "https://plus.unsplash.com/premium_photo-1673439304183-8840bd0dc1bf?q=80&w=687&auto=format&fit=crop",
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                memCacheWidth: 200,
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["title"],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${item["price"]}",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _buildQtyBtn(Icons.remove, () {
                    controller.updateQuantity(index, item["quantity"] - 1);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "${item["quantity"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildQtyBtn(Icons.add, () {
                    controller.updateQuantity(index, item["quantity"] + 1);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildCouponSection() {
    return Obx(() {
      if (controller.appliedCouponCode.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "'${controller.appliedCouponCode.value}' Applied",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      controller.isFreeDelivery.value
                          ? "Free Delivery"
                          : "₹${controller.discountAmount.value} savings",
                      style: TextStyle(color: Colors.green[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: () {
                  controller.removeCoupon();
                  Get.snackbar(
                    "Removed",
                    "Coupon removed successfully",
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 1),
                  );
                },
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couponController,
                decoration: const InputDecoration(
                  hintText: "Enter Coupon Code",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.discount_outlined, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_couponController.text.isNotEmpty) {
                  String result = controller.applyCoupon(
                    _couponController.text,
                  );
                  if (result == "Success") {
                    _couponController.clear();
                    Get.snackbar(
                      "Success",
                      "Coupon Applied Successfully!",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } else {
                    Get.snackbar(
                      "Failed",
                      result,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                }
              },
              child: const Text(
                "APPLY",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    });
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
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBillRow(
            "Item Total",
            "₹${controller.totalPrice.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 12),

          if (controller.isFreeDelivery.value)
            _buildBillRow(
              "Delivery Fee",
              "FREE",
              color: Colors.green,
              isStrikethrough: true,
              originalValue: "₹40.00",
            )
          else
            _buildBillRow(
              "Delivery Fee",
              "₹${controller.deliveryFee.toStringAsFixed(2)}",
            ),

          const SizedBox(height: 12),
          _buildBillRow(
            "Taxes & Charges",
            "₹${controller.taxAmount.toStringAsFixed(2)}",
          ),

          if (controller.discountAmount.value > 0) ...[
            const SizedBox(height: 12),
            _buildBillRow(
              "Coupon Discount",
              "- ₹${controller.discountAmount.value.toStringAsFixed(2)}",
              color: Colors.green,
            ),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.grey[200], thickness: 1),
          ),
          _buildBillRow(
            "To Pay",
            "₹${controller.grandTotal.toStringAsFixed(2)}",
            isBold: true,
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
    Color? color,
    bool isStrikethrough = false,
    String? originalValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            if (isStrikethrough && originalValue != null)
              Text(
                originalValue,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            if (isStrikethrough) const SizedBox(width: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomCheckoutBar() {
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
            onPressed: () {
              final user = _auth.currentUser;
              if (user == null) {
                Get.snackbar("Login Required", "Please log in to continue");
                return;
              }
              Get.to(
                () => PlaceOrderPage(
                  cartItems: controller.cartItems,
                  customerId: user.uid,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${controller.grandTotal.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "TOTAL",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Place Order",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
