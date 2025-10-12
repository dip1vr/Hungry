import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool placingOrder = false;

  double get total {
    double sum = 0;
    for (var item in widget.cartItems) {
      sum += item['price'] * (item['quantity'] ?? 1);
    }
    return sum;
  }

  /// Group items by vendorId
  Map<String, List<Map<String, dynamic>>> groupByVendor() {
    Map<String, List<Map<String, dynamic>>> itemsByVendor = {};
    for (var item in widget.cartItems) {
      String vendorId = item['vendorId'];
      if (!itemsByVendor.containsKey(vendorId)) {
        itemsByVendor[vendorId] = [];
      }
      itemsByVendor[vendorId]!.add(item);
    }
    return itemsByVendor;
  }

  /// Place order for each vendor
  Future<void> placeOrder() async {
  if (widget.cartItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cart is empty')),
    );
    return;
  }

  setState(() => placingOrder = true);

  try {
    final itemsByVendor = groupByVendor();

    // 🔹 Debug: Print grouped vendors
    print("==== Grouped Vendors & Items ====");
    itemsByVendor.forEach((vendorId, items) {
      print("Vendor ID: $vendorId");
      for (var item in items) {
        print("  Item: ${item['title']} x ${item['quantity']}");
      }
    });
    print("===============================");

    List<String> orderIds = [];

    // 🔹 Loop over each vendor
    for (var vendorId in itemsByVendor.keys) {
  var vendorItems = itemsByVendor[vendorId]!;
  print("Processing order for Vendor: $vendorId");
  for (var item in vendorItems) {
    print("  Item: ${item['title']} x ${item['quantity']}");
  }

  try {
    // Calculate total for this vendor
    double vendorTotal = vendorItems.fold(
      0,
      (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1)),
    );
    print("Vendor Total: $vendorTotal");

    // Create main order
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    print("Creating main order: ${orderRef.id}");
    await orderRef.set({
      'customerId': widget.customerId,
      'vendorId': vendorId,
      'status': 'pending',
      'total': vendorTotal,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("Main order created: ${orderRef.id}");

    // Add items subcollection
    for (var item in vendorItems) {
      print("Adding item: ${item['title']} to order ${orderRef.id}");
      await orderRef.collection('items').add({
        'title': item['title'],
        'price': item['price'],
        'quantity': item['quantity'] ?? 1,
      });
    }
    print("Items added for order: ${orderRef.id}");

    // Vendor-specific order + notification
    print("Creating vendor order for: $vendorId");
    await FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .collection('orders')
        .doc(orderRef.id)
        .set({
      'orderId': orderRef.id,
      'status': 'pending',
      'customerId': widget.customerId,
      'total': vendorTotal,
      'items': vendorItems
          .map((e) => {
                'title': e['title'],
                'price': e['price'],
                'quantity': e['quantity'] ?? 1,
              })
          .toList(),
      'timestamp': FieldValue.serverTimestamp(),
      'newOrder': true,
    });
    print("Vendor order created: ${orderRef.id}");

    // Delivery order
    print("Creating delivery order: ${orderRef.id}");
    await FirebaseFirestore.instance
        .collection('deliveryOrders')
        .doc(orderRef.id)
        .set({
      'orderId': orderRef.id,
      'status': 'pending',
      'customerId': widget.customerId,
      'vendorId': vendorId,
      'total': vendorTotal,
      'acceptedBy': null,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("Delivery order created: ${orderRef.id}");

    orderIds.add(orderRef.id);
    print("Order created for Vendor: $vendorId with ID: ${orderRef.id}");
  } catch (e) {
    print("Error processing vendor $vendorId: $e");
    continue; // Continue to the next vendor instead of stopping
  }
}
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Order Placed',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Your order total is ₹${total.toStringAsFixed(2)}.\n'
            'Orders have been sent to ${itemsByVendor.keys.length} vendor(s).',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepOrange, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    print("Error placing order: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  } finally {
    setState(() => placingOrder = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        title: Text(
          "Place Your Order",
          style: GoogleFonts.permanentMarker(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (_, index) {
                      var item = widget.cartItems[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            item['title'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '₹${item['price'].toStringAsFixed(2)} x ${item['quantity'] ?? 1}',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                          trailing: Text(
                            '₹${(item['price'] * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: placingOrder ? null : placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepOrange, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: placingOrder
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text(
                              'Place Order',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
