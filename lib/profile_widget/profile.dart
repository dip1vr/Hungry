import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hungry/profile_widget/edit_profile.dart';
import 'package:hungry/profile_widget/saved_addresses.dart';
import 'package:shimmer/shimmer.dart'; // <-- shimmer package

// Primary colors
const kPrimaryColor = Color(0xFFFF8C00);
const kAccentColor = Color(0xFFE91E63);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;

  // User data
  String name = "";
  String email = "";
  String phone = "";
  String address = "";
  String landmark = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser!.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            name = data['name'] ?? "";
            phone = data['phone'] ?? "";
            address = data['address'] ?? "";
            landmark = data['landmark'] ?? "";
            email = refreshedUser.email ?? "";
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Error fetching user data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image (same as before)
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Midjourney.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main content always visible; only the details area will show shimmer while loading
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header Section (Avatar + name + email) - show shimmer placeholders while loading
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Avatar with gradient border
                            Container(
                              width: 128,
                              height: 128,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.cyan, Colors.teal],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: CircleAvatar(
                                  radius: 58,
                                  backgroundColor: Colors.orange,
                                  child: _isLoading
                                      ? _buildAvatarShimmer()
                                      : const CircleAvatar(
                                          radius: 58,
                                          backgroundImage: NetworkImage(
                                              "https://i.pravatar.cc/150?img=5"),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: kAccentColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Name
                        _isLoading ? _buildLineShimmer(width: 160, height: 22, radius: 8) :
                        Text(
                          name.isNotEmpty ? name : "No Name",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Email
                        _isLoading ? _buildLineShimmer(width: 180, height: 14, radius: 6) :
                        Text(
                          email.isNotEmpty ? email : "No Email",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.85),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // User Details Card — THIS is where we show shimmer/skeleton while loading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "User Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // if loading -> show skeleton rows, else actual rows
                              if (_isLoading) ...[
                                _buildDetailSkeletonRow(),
                                const SizedBox(height: 10),
                                _buildDetailSkeletonRow(),
                                const SizedBox(height: 10),
                                _buildDetailSkeletonRow(),
                                const SizedBox(height: 10),
                                _buildDetailSkeletonRow(),
                                const SizedBox(height: 10),
                                _buildDetailSkeletonRow(),
                                const SizedBox(height: 20),
                              ] else ...[
                                _buildDetailRow(
                                    icon: Icons.person,
                                    label: "Name",
                                    value: name.isNotEmpty ? name : "No Name"),
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                    icon: Icons.email,
                                    label: "Email",
                                    value: email.isNotEmpty ? email : "No Email"),
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                    icon: Icons.phone,
                                    label: "Phone",
                                    value: phone.isNotEmpty ? phone : "Not added"),
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                    icon: Icons.location_on,
                                    label: "Address",
                                    value: address.isNotEmpty ? address : "Not added"),
                                const SizedBox(height: 10),
                                _buildDetailRow(
                                    icon: Icons.flag,
                                    label: "Landmark",
                                    value: landmark.isNotEmpty ? landmark : "Not added"),
                                const SizedBox(height: 20),
                              ]
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: -15,
                          right: -15,
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const EditProfilePage()),
                              );
                              _fetchUserData(); // refresh after editing
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [kPrimaryColor, kAccentColor],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Menu Section (unchanged)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildMenuCard(
                          context,
                          icon: Icons.history,
                          title: "Order History",
                          subtitle: "View your past orders",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const OrderHistoryPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildMenuCard(
                          context,
                          icon: Icons.favorite,
                          title: "Favorites",
                          subtitle: "Your favorite items",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const FavoritesPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Footer
                  Text(
                    "Version 2.0.1",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Shimmer / Skeleton helper widgets using `shimmer` package ----------------

  Widget _buildAvatarShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: const CircleAvatar(radius: 58, backgroundColor: Colors.white),
    );
  }

  Widget _buildLineShimmer({double width = 120, double height = 14, double radius = 6}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildDetailSkeletonRow() {
    return Row(
      children: [
        // icon circle
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // label small line
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // value longer line
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 150,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- original helper widgets (unchanged) ----------------

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: kPrimaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = kPrimaryColor,
    Color textColor = Colors.black87,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade500,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Separate Pages =====

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: kPrimaryColor,
      ),
      body: const Center(
        child: Text("Order History content here"),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: kPrimaryColor,
      ),
      body: const Center(
        child: Text("Favorites content here"),
      ),
    );
  }
}
