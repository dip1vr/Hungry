import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/dashboard/controllers/dashboard_controller.dart';
import 'package:hungry/features/dashboard/widgets/restaurant_card.dart';
import 'package:hungry/features/dashboard/widgets/food_item_card.dart';
import 'package:hungry/features/dashboard/pages/food_details_page.dart';
import 'package:hungry/features/order/controllers/food_controller.dart';

class SearchResultsSection extends StatelessWidget {
  const SearchResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find();

    return Obx(() {
      if (controller.isSearchLoading.value) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5200)),
            ),
          ),
        );
      }

      final restaurants = controller.searchResultsRestaurants;
      final foodItems = controller.searchResultsFood;

      if (restaurants.isEmpty && foodItems.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No results found",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildListDelegate([
          if (restaurants.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Text(
                "Restaurants",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...restaurants.map((doc) {
              final rawData = doc.data() as Map<String, dynamic>;
              final data = {
                'name': rawData['restaurantName'] ?? 'Unknown',
                'cuisine': rawData['cuisineType'] ?? 'No Category',
                'rating': (rawData['rating'] ?? 4.5).toString(),
                'time': rawData['prepairTime'] ?? '20-30 min',
                'offer': 'Suggested',
                'featured': false,
                'fast': true,
                'tags': ['Result'],
                'img':
                    rawData['imageUrl'] ??
                    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
              };

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: RestaurantCard(data: data, restaurantId: doc.id),
              );
            }),
          ],

          if (foodItems.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Text(
                "Food Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...foodItems.map((doc) {
              final rawData = doc.data() as Map<String, dynamic>;
              final data = {
                'name': rawData['name'] ?? 'Food Name',
                'desc': rawData['description'] ?? 'Delicious food',
                'price': "₹${rawData['price']}",
                'oldPrice': rawData['oldPrice'] != null
                    ? "₹${rawData['oldPrice']}"
                    : null,
                'img':
                    rawData['imageUrl'] ??
                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                'time': rawData['prepairTime'] ?? '20-30 min',
                'rating': (rawData['rating'] ?? 4.5).toString(),
                'bestseller': rawData['bestseller'] ?? false,
              };

              return GestureDetector(
                onTap: () {
                  Get.to(() => FoodDetailsPage(data: data));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: FoodItemCard(
                    data: data,
                    onAdd: () {
                      final FoodController foodController = Get.find();
                      foodController.addToCart({
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
                      });
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
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 100),
        ]),
      );
    });
  }
}
