import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hungry/features/order/controllers/food_controller.dart';
import 'package:hungry/common/widgets/optimized_network_image.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: Text(
          "Checkout",
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
                  _buildSectionTitle("Delivery Address"),
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
                  "Home",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "123, Main Street, Springfield, IL 62704", // This should ideally come from ProfileController
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to change address
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
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${item['quantity']} x ₹${item['price']}",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
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
              style: GoogleFonts.poppins(
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
          _buildBillRow(
            "Item Total",
            "₹${controller.totalPrice.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 10),
          _buildBillRow(
            "Delivery Fee",
            controller.isFreeDelivery.value ? "FREE" : "₹40.00",
            color: controller.isFreeDelivery.value
                ? Colors.green
                : Colors.black87,
          ),
          const SizedBox(height: 10),
          if (controller.discountAmount.value > 0)
            _buildBillRow(
              "Discount",
              "-₹${controller.discountAmount.value.toStringAsFixed(2)}",
              color: Colors.green,
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
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.black87,
          ),
        ),
      ],
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
    setState(() => placingOrder = true);

    try {
      final itemsByVendor = groupByVendor();

      for (var vendorId in itemsByVendor.keys) {
        var vendorItems = itemsByVendor[vendorId]!;

        // Calculate vendor-specific total (pro-rated logic could be complex with coupons,
        // for now we just store the items price, and the main order has the discounted grand total)
        // Ideally, we split the discount across vendors, but for this MVP:
        // Main Order -> Grand Total (Customer Pay)
        // Vendor Order -> Vendor Items Total (Vendor Receive)

        double vendorTotal = vendorItems.fold(
          0,
          (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1)),
        );

        final orderRef = FirebaseFirestore.instance.collection('orders').doc();

        // Main Order Record
        // Main Order Record
        await orderRef.set({
          'userId': widget.customerId, // Matched with OrderHistoryController
          'vendorId': vendorId,
          'status': 'pending',
          'totalAmount':
              controller.grandTotal, // Matched with OrderHistoryController
          'subTotal': vendorTotal,
          'discount': controller.discountAmount.value,
          'coupon': controller.appliedCouponCode.value,
          'paymentMethod': _selectedPaymentMethod == 0
              ? 'COD'
              : (_selectedPaymentMethod == 1 ? 'UPI' : 'Card'),
          'createdAt':
              FieldValue.serverTimestamp(), // Matched with OrderHistoryController
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
              'totalAmount': controller.grandTotal,
              'subTotal': vendorTotal,
              'discount': controller.discountAmount.value,
              'paymentMethod': _selectedPaymentMethod == 0
                  ? 'COD'
                  : (_selectedPaymentMethod == 1 ? 'UPI' : 'Card'),
              'createdAt': FieldValue.serverTimestamp(),
              'items': vendorItems,
            });

        // Add items
        for (var item in vendorItems) {
          await orderRef.collection('items').add({
            'title': item['title'],
            'price': item['price'],
            'quantity': item['quantity'] ?? 1,
            'imageUrl': item['imageUrl'],
          });
        }

        // Vendor Notification Record
        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(vendorId)
            .collection('orders')
            .doc(orderRef.id)
            .set({
              'orderId': orderRef.id,
              'status': 'pending',
              'customerId': widget.customerId,
              'total': vendorTotal, // Vendor sees their items total
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
            });

        // Delivery Record
        await FirebaseFirestore.instance
            .collection('deliveryOrders')
            .doc(orderRef.id)
            .set({
              'orderId': orderRef.id,
              'status': 'pending',
              'customerId': widget.customerId,
              'vendorId': vendorId,
              'total': controller.grandTotal, // Delivery collects this
              'timestamp': FieldValue.serverTimestamp(),
            });
      }

      // Success!
      if (mounted) {
        Get.defaultDialog(
          title: "Order Placed!",
          titleStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
