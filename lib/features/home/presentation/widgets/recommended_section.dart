import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hungry/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:hungry/features/home/presentation/widgets/food_item_card.dart';
import 'package:hungry/features/home/presentation/widgets/food_item_skeleton.dart';
import 'package:hungry/features/home/presentation/widgets/restaurant_card.dart';
import 'package:hungry/features/orders/presentation/controllers/food_controller.dart';

class RecommendedSectionSliver extends StatelessWidget {
  const RecommendedSectionSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find();

    return Obx(() {
      final items = controller.recommendedItems;

      if (items.isEmpty) {
        // Show Skeleton in a SliverList
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Recommended for You"),
              SizedBox(height: 20),
              Column(
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
              ),
            ],
          ),
        );
      }

      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Recommended for You"),
                SizedBox(height: 20),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final restaurants = controller.featuredRestaurants;
                final bool showRestaurants = restaurants.isNotEmpty;
                final int foodCount = items.length;

                // Calculate total content count based on whether we show restaurants
                final int totalContentCount = showRestaurants
                    ? foodCount + (foodCount ~/ 5)
                    : foodCount;

                if (index >= totalContentCount) {
                  // Loading indicator at the bottom
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 24.0,
                    ),
                    child: Center(child: FoodItemSkeleton()),
                  );
                }

                if (!showRestaurants) {
                  // Simple list without restaurants
                  if (index >= items.length) return SizedBox.shrink();
                  final foodDoc = items[index];
                  return _buildFoodItem(foodDoc);
                }

                // Logic: Insert a restaurant after every 5 food items.
                bool isRestaurantSlot = (index + 1) % 6 == 0;

                if (isRestaurantSlot) {
                  // Calculate which restaurant to show (cycle through logic)
                  final int restaurantIndex = (index ~/ 6) % restaurants.length;
                  final doc = restaurants[restaurantIndex];
                  final data = doc.data() as Map<String, dynamic>;

                  final restaurantData = {
                    'name': data['restaurantName'] ?? 'Unknown',
                    'cuisine': data['cuisineType'] ?? 'No Category',
                    'rating': (data['rating'] ?? 4.5).toString(),
                    'time': data['prepairTime'] ?? '20-30 min',
                    'offer': 'Suggested for you',
                    'featured': false,
                    'fast': true,
                    'tags': ['Recommended'],
                    'img':
                        data['imageUrl'] ??
                        'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
                  };

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 24,
                      left: 16,
                      right: 16,
                    ),
                    child: RepaintBoundary(
                      child: RestaurantCard(
                        data: restaurantData,
                        restaurantId: doc.id,
                      ),
                    ),
                  );
                }

                // It is a food item
                final int numRestaurantsBefore = index ~/ 6;
                final int foodIndex = index - numRestaurantsBefore;

                if (foodIndex >= items.length) return SizedBox.shrink();

                final foodDoc = items[foodIndex];
                return _buildFoodItem(foodDoc);
              },
              // Child Count Calculation
              // Total content + 1 for loader if hasMore is true
              childCount:
                  (controller.featuredRestaurants.isNotEmpty
                      ? (items.length + (items.length ~/ 5))
                      : items.length) +
                  (controller.hasMore.value ? 1 : 0),
            ),
          ),
        ],
      );
    });
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

  Widget _buildFoodItem(DocumentSnapshot foodDoc) {
    final foodData = foodDoc.data() as Map<String, dynamic>? ?? {};
    final vendorRef = foodDoc.reference.parent.parent;
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
      'vendorId': vendorId,
      'itemOffer': foodData['offer'],
      'category': foodData['category'] ?? 'Other',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      child: RepaintBoundary(
        // isolate repaints
        child: FoodItemCard(
          data: foodItem,
          onAdd: () {
            final cartController = Get.put(
              FoodController(),
            ); // Ensure existing instance
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
              "itemOffer": foodData['offer'],
            };
            cartController.addToCart(cartItem);
          },
        ),
      ),
    );
  }
}
