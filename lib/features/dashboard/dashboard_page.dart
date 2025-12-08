import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/dashboard/controllers/dashboard_controller.dart';
import 'package:hungry/features/dashboard/widgets/bottom_nav_bar.dart';
import 'package:hungry/features/dashboard/widgets/categories_widget.dart';
import 'package:hungry/features/dashboard/widgets/featured_restaurants.dart';
import 'package:hungry/features/dashboard/widgets/header_widget.dart';
import 'package:hungry/features/dashboard/widgets/mood_section.dart';
import 'package:hungry/features/dashboard/widgets/promo_carousel.dart';
import 'package:hungry/features/dashboard/widgets/recommended_section.dart';
import 'package:hungry/features/dashboard/widgets/search_bar_widget.dart';
import 'package:hungry/features/dashboard/widgets/section_title.dart';
import 'package:hungry/features/cart/cart_page.dart';
import 'package:hungry/features/order/controllers/food_controller.dart';
import 'package:hungry/features/profile/profile_page.dart';
import 'package:hungry/features/profile/favorites_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final DashboardController dashboardController = Get.put(
      DashboardController(),
    );
    final FoodController foodController = Get.put(FoodController());

    // Pages list
    final List<Widget> pages = [
      _buildHomeContent(),
      const Center(child: Text("Dining Page - Coming Soon")),
      const FavoritesPage(), // Offers/Likes mapped to Favorites for now
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Stack(
          children: [
            // Page Content with Obx
            // Page Content with PageView for sliding animation
            PageView(
              controller: dashboardController.pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                // Update the selected index without triggering animation loop
                dashboardController.selectedIndex.value = index;
              },
              children: pages,
            ),

            // Bottom Nav Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(
                () => BottomNavBarWidget(
                  selectedIndex: dashboardController.selectedIndex.value,
                  onTap: (index) {
                    dashboardController.changeIndex(index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildCartButton(foodController),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          HeaderWidget(),
          SizedBox(height: 16),
          SearchBarWidget(),
          SizedBox(height: 24),
          PromoCarousel(),
          SizedBox(height: 24),
          SectionTitle(title: "What's on your mind?"),
          SizedBox(height: 16),
          CategoriesWidget(),
          SizedBox(height: 24),
          SectionTitle(title: "What's the mood"),
          MoodSection(),
          SizedBox(height: 24),
          SectionTitle(title: "Featured Restaurants"),
          FeaturedRestaurantsSection(),
          SizedBox(height: 32),
          RecommendedSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCartButton(FoodController controller) {
    return Obx(() {
      return controller.cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.to(() => CartPage());
              },
              backgroundColor: Colors.green.withOpacity(0.9),
              label: Text(
                "${controller.cartItems.length} Item${controller.cartItems.length > 1 ? 's' : ''} | ₹${controller.totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
            )
          : const SizedBox.shrink();
    });
  }
}
