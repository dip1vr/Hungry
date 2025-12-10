import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/dashboard/widgets/restaurant_card.dart';
import 'package:hungry/features/profile/controllers/favorites_controller.dart';

const kPrimaryColor = Color(0xFFFF5200);
const kBgColor = Color(0xFFF4F6F8);

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoritesController controller = Get.put(FavoritesController());

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.favoriteItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "No favorites yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.favoriteItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final data = controller.favoriteItems[index];
            return RestaurantCard(
              data: data,
              restaurantId:
                  data['id'] ??
                  "", // Uses 'id' we injected in existing controller logic, or handle gracefully
            );
          },
        );
      }),
    );
  }
}
