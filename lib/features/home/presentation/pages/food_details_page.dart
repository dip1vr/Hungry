import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/orders/presentation/controllers/food_controller.dart';

class FoodDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const FoodDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final FoodController foodController = Get.put(FoodController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Hero(
                    tag: 'food_img_${data['name']}',
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(data['img'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    data['name'] ?? 'Food Name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${data['time'] ?? '20-30 min'} • ${data['rating'] ?? '4.5'} ⭐",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        data['price'] ?? '₹0',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFF5200),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (data['oldPrice'] != null)
                        Text(
                          data['oldPrice'],
                          style: TextStyle(
                            fontSize: 20,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    data['desc'] ??
                        "Delicious food prepared with fresh ingredients. Taste the authentic flavors in every bite.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate Add to cart
                  // Map simplified data to Cart Item format
                  final cartItem = {
                    "title": data['name'],
                    "price":
                        int.tryParse(
                          data['price'].toString().replaceAll(
                            RegExp(r'[^0-9]'),
                            '',
                          ),
                        ) ??
                        0,
                    "imageUrl": data['img'],
                    "quantity": 1,
                    "description": data['desc'],
                  };
                  foodController.addToCart(cartItem);
                  Get.back();
                  Get.snackbar(
                    "Added to Cart",
                    "${data['name']} added to your cart",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  "Add to Cart",
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
    );
  }
}
