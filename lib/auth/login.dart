import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// -------------------- CONTROLLER --------------------
class FoodController extends GetxController {
  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  void addToCart(Map<String, dynamic> foodItem) {
    cartItems.add(foodItem);
  }
}

/// -------------------- MAIN PAGE --------------------
class FoodHomePage extends StatelessWidget {
  FoodHomePage({super.key});

  final FoodController controller = Get.put(FoodController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // ✅ Transparent Background
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collectionGroup("menuItems").snapshots(),
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
            itemCount: foods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final f = foods[index].data() as Map<String, dynamic>? ?? {};
              final vendorRef = foods[index].reference.parent.parent;
              final vendorId = vendorRef?.id ?? "unknown";

              Map<String, dynamic> foodItem = {
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
              };

              return FoodCard(
                food: foodItem,
                onAdd: () => controller.addToCart(foodItem),
              );
            },
          );
        },
      ),
    );
  }
}

/// -------------------- FOOD CARD --------------------
class FoodCard extends StatelessWidget {
  final Map<String, dynamic> food;
  final VoidCallback onAdd;

  const FoodCard({super.key, required this.food, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          /// --- IMAGE SECTION ---
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              food["imageUrl"] ??
                  "https://plus.unsplash.com/premium_photo-1673439304183-8840bd0dc1bf?q=80&w=687&auto=format&fit=crop",
              height: 132,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),

          /// --- DETAILS SECTION ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (food["rating"] != null && food["rating"] >= 4.5)
                    const Text(
                      "● BESTSELLER",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  const SizedBox(height: 8),

                  Text(
                    food["title"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    food["tags"].isNotEmpty ? food["tags"][0] : "Restaurant",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        "₹${food["price"]} ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        "₹${food["oldPrice"]}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      Text(" ${food["rating"]}"),
                      const SizedBox(width: 8),
                      const Icon(Icons.timer, size: 14, color: Colors.grey),
                      Text(" ${food["time"]}"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// --- PLUS BUTTON ---
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 30,
              width: 30,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C00), Color(0xFFFF4E50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child:
                  const Icon(Icons.add_outlined, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
