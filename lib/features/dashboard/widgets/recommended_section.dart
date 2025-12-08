import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/dashboard/widgets/food_item_card.dart';
import 'package:hungry/features/dashboard/widgets/food_item_skeleton.dart';
import 'package:hungry/features/order/controllers/food_controller.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Recommended for You"),
        const SizedBox(height: 20),

        // Firebase StreamBuilder for food items
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup("menuItems")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text("Error: ${snapshot.error}"),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: FoodItemSkeleton(),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("No food items available"),
                ),
              );
            }

            final foodDocs = snapshot.data!.docs;

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: foodDocs.length,
              separatorBuilder: (_, __) => SizedBox(height: 24),
              itemBuilder: (context, index) {
                final foodData =
                    foodDocs[index].data() as Map<String, dynamic>? ?? {};
                final vendorRef = foodDocs[index].reference.parent.parent;
                final vendorId = vendorRef?.id ?? "unknown";

                // Map Firebase data to our card format
                final foodItem = {
                  'name': foodData['name'] ?? 'Unknown Dish',
                  'desc': foodData['description'] ?? 'No description',
                  'price': '₹${foodData['price'] ?? 0}',
                  'oldPrice': '₹${(foodData['price'] ?? 0) + 50}',
                  'rating': (foodData['rating'] ?? 4.5).toString(),
                  'time': '20-30 min',
                  'img':
                      foodData['imageUrl'] ??
                      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
                  'bestseller': (foodData['rating'] ?? 0) >= 4.5,
                };

                return RepaintBoundary(
                  child: FoodItemCard(
                    data: foodItem,
                    onAdd: () {
                      // Add to cart
                      final controller = Get.put(FoodController());
                      final cartItem = {
                        "title": foodData['name'] ?? 'Unknown Dish',
                        "desc": foodData['description'] ?? 'No description',
                        "price": foodData['price'] ?? 0,
                        "oldPrice": (foodData['price'] ?? 0) + 50,
                        "time": "20-30 min",
                        "cal": "350 cal",
                        "tags": [foodData['category'] ?? "Other"],
                        "rating": foodData['rating'] ?? 4.5,
                        "imageUrl": foodData['imageUrl'],
                        "quantity": 1,
                        "vendorId": vendorId,
                      };
                      controller.addToCart(cartItem);
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Color(0xFFFF5200),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
