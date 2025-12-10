import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/dashboard/controllers/dashboard_controller.dart';
import 'package:hungry/features/dashboard/widgets/bottom_nav_bar.dart';
import 'package:hungry/features/dashboard/widgets/categories_widget.dart';
import 'package:hungry/features/dashboard/widgets/featured_restaurants.dart';
import 'package:hungry/features/dashboard/widgets/header_widget.dart';
import 'package:hungry/features/dashboard/widgets/mood_section.dart';
import 'package:hungry/features/dashboard/widgets/promo_carousel.dart';
// import 'package:hungry/features/dashboard/widgets/recommended_section.dart'; // We will update this file to export RecommendedSectionSliver
import 'package:hungry/features/dashboard/widgets/recommended_section.dart';
import 'package:hungry/features/dashboard/widgets/search_bar_widget.dart';
import 'package:hungry/features/dashboard/widgets/section_title.dart';
import 'package:hungry/features/dashboard/widgets/search_results_section.dart';
import 'package:hungry/features/order/controllers/food_controller.dart';
import 'package:hungry/features/profile/profile_page.dart';
import 'package:hungry/features/profile/favorites_page.dart';
import 'package:hungry/features/dashboard/widgets/modern_cart_button.dart';
import 'package:hungry/features/profile/controllers/profile_controller.dart';
import 'package:hungry/features/profile/controllers/favorites_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final DashboardController dashboardController = Get.put(
      DashboardController(),
    );
    final FoodController foodController = Get.put(FoodController());
    Get.put(
      ProfileController(),
    ); // Initialize ProfileController for HeaderWidget
    Get.put(
      FavoritesController(),
      permanent: true,
    ); // Initialize FavoritesController globally

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

            // Modern Cart Button (Floating above Nav)
            const Positioned(
              bottom: 100, // Above the Bottom Nav
              right: 0,
              left: 0, // Center it horizontally or just right aligned?
              // The widget itself has `right: 16` margin effectively if I constrain it or I can just let it be aligned.
              // Let's align it to the right as per usual FAB, or center?
              // The user image shows it cropped on the right. Let's make it a nice right-aligned-ish or center pill.
              // Current implementation of ModernCartButton has `margin: only(bottom: 60, right: 16)`.
              // So if I wrap it in a Positioned(bottom:0, right:0), it will sit 60px up and 16px left.
              // Let's stick effectively to that.
              child: Align(
                alignment: Alignment.bottomRight,
                child: ModernCartButton(),
              ),
            ),
          ],
        ),
      ),
      // Removed floatingActionButton
    );
  }

  Widget _buildHomeContent() {
    // Get controller to access scrollController
    final DashboardController dashboardController = Get.find();

    return Obx(
      () => CustomScrollView(
        controller: dashboardController.scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: const HeaderWidget()),
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(child: const SearchBarWidget()),
          SliverToBoxAdapter(child: SizedBox(height: 24)),

          if (dashboardController.isSearching.value)
            const SearchResultsSection()
          else ...[
            SliverToBoxAdapter(child: const PromoCarousel()),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: const SectionTitle(title: "What's on your mind?"),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: const CategoriesWidget()),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: const SectionTitle(title: "What's the mood"),
            ),
            SliverToBoxAdapter(child: const MoodSection()),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: const SectionTitle(title: "Featured Restaurants"),
            ),
            SliverToBoxAdapter(child: const FeaturedRestaurantsSection()),
            SliverToBoxAdapter(child: SizedBox(height: 32)),
            const RecommendedSectionSliver(),
            SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
          ],
        ],
      ),
    );
  }
}
