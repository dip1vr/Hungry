import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hungry/common/widgets/optimized_network_image.dart';
import 'package:hungry/features/profile/controllers/profile_controller.dart';
import 'package:hungry/features/profile/edit_profile_page.dart';
import 'package:hungry/features/profile/order_history_page.dart';
import 'package:hungry/features/profile/favorites_page.dart';
import 'package:shimmer/shimmer.dart';

// Primary colors - Matches Dashboard Theme
const kPrimaryColor = Color(0xFFFF5200); // Vibrant Orange
const kBgColor = Color(0xFFF4F6F8); // Light Grey Background

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading();
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Header: Avatar & Name
                _buildProfileHeader(context, controller),

                const SizedBox(height: 30),

                // Menu Options
                _buildSectionTitle("Account"),
                const SizedBox(height: 10),
                _buildProfileOption(
                  icon: Icons.person_outline,
                  title: "Personal Information",
                  subtitle: "Name, Phone, Address",
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    ).then((_) {
                      // Refresh data when returning from edit
                      controller.fetchUserData();
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildProfileOption(
                  icon: Icons.history,
                  title: "Order History",
                  subtitle: "View your past orders",
                  color: Colors.purpleAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderHistoryPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildProfileOption(
                  icon: Icons.favorite_border,
                  title: "Favorites",
                  subtitle: "Your loved items",
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),
                _buildSectionTitle("Settings"),
                const SizedBox(height: 10),
                _buildProfileOption(
                  icon: Icons.map_outlined,
                  title: "Saved Addresses",
                  subtitle: controller.address.value.isNotEmpty
                      ? controller.address.value
                      : "Manage addresses",
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    ).then((_) => controller.fetchUserData());
                  },
                ),
                const SizedBox(height: 16),
                _buildProfileOption(
                  icon: Icons.logout,
                  title: "Log Out",
                  subtitle: "Sign out of your account",
                  color: Colors.orange,
                  isDestructive: true,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),

                const SizedBox(height: 40),
                Text(
                  "Version 2.0.1",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ProfileController controller,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: OptimizedNetworkImage(
                  imageUrl: "https://i.pravatar.cc/300?img=12", // Modern avatar
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  memCacheWidth: 300,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
                controller.fetchUserData();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          controller.name.isNotEmpty ? controller.name.value : "Guest User",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          controller.email.isNotEmpty
              ? controller.email.value
              : "guest@hungry.com",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDestructive ? Colors.red : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Avatar Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Text Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(width: 150, height: 20, color: Colors.white),
          ),
          const SizedBox(height: 50),
          // Card Shimmers
          for (int i = 0; i < 3; i++) ...[
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
