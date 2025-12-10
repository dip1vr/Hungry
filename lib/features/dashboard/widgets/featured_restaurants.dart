import 'package:flutter/material.dart';
import 'package:hungry/features/dashboard/widgets/restaurant_card.dart';
import 'package:get/get.dart';
import 'package:hungry/features/dashboard/controllers/dashboard_controller.dart';

class FeaturedRestaurantsSection extends StatelessWidget {
  const FeaturedRestaurantsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        SizedBox(
          height: 360,
          child: Obx(() {
            final restaurants = controller.featuredRestaurants;

            if (restaurants.isEmpty) {
              // Should show Shimmer/Skeleton here ideally
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final doc = restaurants[index];
                final data = doc.data() as Map<String, dynamic>;

                // Map Firebase data to our card format
                final restaurantData = {
                  'name': data['restaurantName'] ?? 'Unknown',
                  'cuisine': data['cuisineType'] ?? 'No Category',
                  'rating': (data['rating'] ?? 4.5).toString(),
                  'time': data['prepairTime'] ?? '20-30 min',
                  'offer': '50% OFF', // Default offer
                  'featured': true,
                  'fast': true,
                  'tags': ['popular', 'trending'],
                  'img':
                      data['imageUrl'] ??
                      'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
                };

                return RepaintBoundary(
                  child: RestaurantCard(
                    data: restaurantData,
                    restaurantId: doc.id,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
