import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hungry/shared/widgets/optimized_network_image.dart';
import 'package:hungry/features/orders/presentation/controllers/food_controller.dart';
import 'package:hungry/features/orders/presentation/pages/order_place_page.dart';

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
                          _buildSuggestedOffers(),
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Looks like you haven't added\nany food yet.",
            textAlign: TextAlign.center,
            style: TextStyle(
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${item["price"]}",
                    style: TextStyle(
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
                      style: TextStyle(
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

  Widget _buildSuggestedOffers() {
    return Obx(() {
      if (controller.suggestedOffers.isEmpty ||
          controller.appliedCouponCode.isNotEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.suggestedOffers.length,
          itemBuilder: (context, index) {
            final offer = controller.suggestedOffers[index];
            final title = (offer['title'] ?? 'OFFER').toString();
            final desc = (offer['description'] ?? '').toString();
            final code = (offer['code'] ?? offer['couponCode'] ?? title)
                .toString();
            final val = offer['discountValue'];
            final isPercent =
                offer['discountType'] == 'percentage' ||
                offer['discountType'] == 'percent';

            String discStr = isPercent ? "$val% OFF" : "₹$val OFF";

            return GestureDetector(
              onTap: () {
                String result = controller.applyCoupon(code);
                if (result == "Success") {
                  Get.snackbar(
                    "Applied!",
                    "'$code' applied successfully",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                } else {
                  Get.snackbar(
                    "Error",
                    result,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Container(
                width: 250,
                margin: const EdgeInsets.only(right: 12, bottom: 4, top: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade100, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Small Ticket Cutouts
                    Positioned(
                      left: -6,
                      top: 40,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: kBgColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange.shade100),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -6,
                      top: 40,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: kBgColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange.shade100),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_offer_rounded,
                              color: kPrimaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: kPrimaryColor,
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      discStr,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF065F46),
                                      ),
                                    ),
                                  ],
                                ),
                                if (desc.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    desc,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey[600],
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    code.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black54,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Min Order Info
                                Row(
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final minAmt =
                                            offer['minOrderValue'] ??
                                            offer['minAmount'] ??
                                            offer['minOrder'] ??
                                            0;
                                        final vendorId = offer['vendorId'];
                                        double relevantTotal =
                                            controller.totalPrice;

                                        if (vendorId != null) {
                                          final bool isItemSpecific =
                                              offer['isItemSpecific'] == true;
                                          final String? itemTitle =
                                              offer['sourceItemTitle'];

                                          relevantTotal = controller.cartItems
                                              .where((item) {
                                                bool matchesGroup =
                                                    item['vendorId'] ==
                                                    vendorId;
                                                if (isItemSpecific &&
                                                    itemTitle != null) {
                                                  matchesGroup =
                                                      matchesGroup &&
                                                      item['title'] ==
                                                          itemTitle;
                                                }
                                                return matchesGroup;
                                              })
                                              .fold(
                                                0.0,
                                                (sum, item) =>
                                                    sum +
                                                    (item["price"] *
                                                        item["quantity"]),
                                              );
                                        }

                                        final isMet =
                                            relevantTotal >= (minAmt as num);
                                        return Row(
                                          children: [
                                            Icon(
                                              isMet
                                                  ? Icons.check_circle_rounded
                                                  : Icons.info_outline_rounded,
                                              size: 10,
                                              color: isMet
                                                  ? Colors.green
                                                  : Colors.orange.shade300,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              minAmt > 0
                                                  ? "Min order: ₹$minAmt"
                                                  : "No minimum order",
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: isMet
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: isMet
                                                    ? Colors.green[700]
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey[200], thickness: 1),
          ),

          // 2. Calculations
          // Gross Total
          _buildBillRow(
            "Item Total",
            "₹${controller.totalPrice.toStringAsFixed(2)}",
          ),

          // Discount
          if (controller.discountAmount.value > 0) ...[
            const SizedBox(height: 8),
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
                  "- ₹${controller.discountAmount.value.toStringAsFixed(2)}",
                  color: Colors.green,
                );
              },
            ),
            const SizedBox(height: 8),
            // Calculated Subtotal (Gross - Discount)
            _buildBillRow(
              "Subtotal",
              "₹${(controller.totalPrice - controller.discountAmount.value).toStringAsFixed(2)}",
              isBold: true, // Make it slightly distinct
              fontSize: 14,
            ),
          ],

          const SizedBox(height: 12),

          // Delivery
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

          // Taxes
          _buildBillRow(
            "Taxes & Charges",
            "₹${controller.taxAmount.toStringAsFixed(2)}",
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.grey[200], thickness: 1),
          ),

          // Final Pay
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
    Color? color,
    bool isStrikethrough = false,
    String? originalValue,
    double? fontSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? (isBold ? 15 : 14),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            if (isStrikethrough && originalValue != null)
              Text(
                originalValue,
                style: TextStyle(
                  fontSize: (fontSize ?? 15) - 2,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            if (isStrikethrough) const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize ?? (isBold ? 15 : 14),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "TOTAL",
                      style: TextStyle(
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
                      style: TextStyle(
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
