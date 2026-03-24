import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/orders/presentation/controllers/food_controller.dart';
import 'package:hungry/features/home/presentation/widgets/food_item_card.dart';

class FoodList extends StatelessWidget {
  const FoodList({super.key});

  @override
  Widget build(BuildContext context) {
    final FoodController controller = Get.put(FoodController());

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup("menuItems")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No menu items available"));
        }

        final foods = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true, // Allows it to fit within the parent scroll
          physics:
              const NeverScrollableScrollPhysics(), // Let parent handle scrolling
          itemCount: foods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final f = foods[index].data() as Map<String, dynamic>? ?? {};
            final vendorRef = foods[index].reference.parent.parent;
            final vendorId = vendorRef?.id ?? "unknown";

            Map<String, dynamic> foodItem = {
              "name": f["name"] ?? "Unknown Dish",
              "desc": f["description"] ?? "No description",
              "price": f["price"] ?? 0,
              "oldPrice": (f["price"] ?? 0) + 20,
              "time": "20-30 min",
              "rating": (f["rating"] ?? 4.5).toString(),
              "category": f["category"] ?? "Other",
              "img": f["imageUrl"],
              "bestseller": (f["rating"] ?? 0) >= 4.5,
              "quantity": 1,
              "vendorId": vendorId,
              "itemOffer": f['offer'],
            };

            return FoodItemCard(
              data: foodItem,
              onAdd: () {
                // Convert back to format controller might expect if necessary, or ensure controller handles this map
                // FoodController addToCart expects specific keys?
                // Let's check FoodController usage in RecommendedSection:
                /*
                   final cartItem = {
                          "title": foodData['name'] ?? 'Unknown Dish',
                          ...
                   };
                   cartController.addToCart(cartItem);
                 */
                // Logic: FoodItemCard doesn't manipulate the data for onAdd, it just calls the callback.
                // So we must provide the CART item map to the controller here.

                final cartItem = {
                  "title": f["name"] ?? "Unknown Dish",
                  "desc": f["description"] ?? "No description",
                  "price": f["price"] ?? 0,
                  "oldPrice": (f["price"] ?? 0) + 20,
                  "time": "20-30 min",
                  "cal": "350 cal",
                  "tags": [f["category"] ?? "Other"],
                  "rating": f["rating"] ?? 4.5,
                  "imageUrl": f["imageUrl"],
                  "quantity": 1,
                  "vendorId": vendorId,
                  "itemOffer": f['offer'],
                };
                controller.addToCart(cartItem);
              },
            );
          },
        );
      },
    );
  }
}
