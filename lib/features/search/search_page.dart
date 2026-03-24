import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/search/controllers/search_controller.dart';
import 'package:hungry/features/orders/presentation/controllers/food_controller.dart';
import 'package:hungry/features/home/presentation/widgets/food_item_card.dart';
import 'package:hungry/features/home/presentation/widgets/restaurant_card.dart';
import 'package:hungry/features/home/presentation/widgets/restaurant_skeleton.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final GlobalSearchController controller = Get.put(GlobalSearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller.searchController,
            autofocus: true,
            onChanged: controller.onSearchChanged,
            style: TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              hintText: "Search for food or restaurants...",
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: Color(0xFFFF5200),
              ),
              suffixIcon: Obx(
                () => controller.searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: controller.clearSearch,
                      )
                    : const SizedBox.shrink(),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchTypeSelector(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }

              if (controller.searchResults.isEmpty &&
                  !controller.isSearching.value) {
                return _buildInitialState();
              }

              if (controller.searchResults.isEmpty &&
                  controller.isSearching.value) {
                return _buildEmptyState();
              }

              return _buildSearchResults();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTypeSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _typeButton('food', 'Food', Icons.fastfood_rounded),
          const SizedBox(width: 12),
          _typeButton('restaurant', 'Restaurants', Icons.store_rounded),
        ],
      ),
    );
  }

  Widget _typeButton(String type, String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.searchType.value == type;
      return GestureDetector(
        onTap: () => controller.setSearchType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF5200) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF5200) : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            "Search for your favorite flavors",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: RestaurantSkeleton(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.no_food_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            "No results found for \"${controller.searchText.value}\"",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          if (controller.recommendedResults.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recommended for you",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRecommendationList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final doc = controller.searchResults[index];
        final data = doc.data() as Map<String, dynamic>;

        if (controller.searchType.value == 'food') {
          // Food Item Card
          final foodItem = {
            'name': data['name'] ?? data['title'] ?? 'Unknown',
            'desc': data['description'] ?? data['desc'] ?? '',
            'price': '₹${data['price'] ?? 0}',
            'oldPrice': data['oldPrice'] != null
                ? '₹${data['oldPrice']}'
                : null,
            'img': data['imageUrl'] ?? data['img'],
            'rating': (data['rating'] ?? 4.0).toString(),
            'bestseller': (data['rating'] ?? 0) >= 4.5,
            'vendorId': doc.reference.parent.parent?.id,
            'itemOffer': data['offer'],
            'category': data['category'] ?? 'Other',
          };
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FoodItemCard(
              data: foodItem,
              onAdd: () {
                final cartController = Get.find<FoodController>();
                final cartItem = {
                  "title": foodItem['name'],
                  "desc": foodItem['desc'],
                  "price": data['price'] ?? 0,
                  "imageUrl": foodItem['img'],
                  "quantity": 1,
                  "vendorId": foodItem['vendorId'],
                  "itemOffer": foodItem['itemOffer'],
                };
                cartController.addToCart(cartItem);
                Get.snackbar(
                  "Added",
                  "${foodItem['name']} added to cart",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 1),
                );
              },
            ),
          );
        } else {
          // Restaurant Card
          final restaurantData = {
            'name': data['restaurantName'] ?? 'Unknown',
            'cuisine': data['cuisineType'] ?? 'Various',
            'rating': (data['rating'] ?? 4.0).toString(),
            'time': data['prepairTime'] ?? '20-30 min',
            'offer': 'Special Offer',
            'img': data['imageUrl'] ?? data['img'],
            'featured': data['isFeatured'] ?? false,
            'fast': true,
          };
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RestaurantCard(data: restaurantData, restaurantId: doc.id),
          );
        }
      },
    );
  }

  Widget _buildRecommendationList() {
    return Column(
      children: controller.recommendedResults.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (controller.searchType.value == 'food') {
          final foodItem = {
            'name': data['name'] ?? 'Unknown',
            'desc': data['description'] ?? '',
            'price': '₹${data['price'] ?? 0}',
            'img': data['imageUrl'],
            'rating': (data['rating'] ?? 4.0).toString(),
            'vendorId': doc.reference.parent.parent?.id,
            'itemOffer': data['offer'],
            'category': data['category'] ?? 'Other',
          };
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FoodItemCard(
              data: foodItem,
              onAdd: () {
                final cartController = Get.find<FoodController>();
                final cartItem = {
                  "title": foodItem['name'],
                  "desc": foodItem['desc'],
                  "price": data['price'] ?? 0,
                  "imageUrl": foodItem['img'],
                  "quantity": 1,
                  "vendorId": foodItem['vendorId'],
                  "itemOffer": foodItem['itemOffer'],
                };
                cartController.addToCart(cartItem);
                Get.snackbar(
                  "Added",
                  "${foodItem['name']} added to cart",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.black87,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 1),
                );
              },
            ),
          );
        } else {
          final restaurantData = {
            'name': data['restaurantName'] ?? 'Unknown',
            'cuisine': data['cuisineType'] ?? 'Various',
            'rating': (data['rating'] ?? 4.0).toString(),
            'time': data['prepairTime'] ?? '20-30 min',
            'img': data['imageUrl'],
          };
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: RestaurantCard(data: restaurantData, restaurantId: doc.id),
          );
        }
      }).toList(),
    );
  }
}
