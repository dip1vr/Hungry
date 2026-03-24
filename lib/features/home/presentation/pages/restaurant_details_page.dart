import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:hungry/shared/widgets/optimized_network_image.dart';
import 'package:hungry/features/home/presentation/widgets/food_item_card.dart';
import 'package:hungry/features/home/presentation/widgets/restaurant_profile_skeleton.dart';
import 'package:hungry/features/orders/presentation/controllers/food_controller.dart';


class RestaurantDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String restaurantId;

  const RestaurantDetailsPage({
    super.key,
    required this.data,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  final List<Map<String, dynamic>> _activeRestaurantOffers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantOffers();
  }

  void _fetchRestaurantOffers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('offers')
        .where('isActive', isEqualTo: true)
        .get();

    final now = DateTime.now();
    _activeRestaurantOffers.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      DateTime? start;
      DateTime? end;

      if (data['startDate'] is Timestamp) {
        start = (data['startDate'] as Timestamp).toDate();
      }
      if (data['endDate'] is Timestamp) {
        end = (data['endDate'] as Timestamp).toDate();
      }

      bool isDateValid = true;
      if (start != null && end != null) {
        isDateValid = now.isAfter(start) && now.isBefore(end);
      }

      if (isDateValid) {
        _activeRestaurantOffers.add(data);
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const RestaurantProfileSkeleton();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Subtle background
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildRestaurantInfo(),
          _buildOffersSection(),
          _buildMenuTitle(),
          _buildMenuList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 18,
          ),
        ),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            OptimizedNetworkImage(
              imageUrl: widget.data['img'],
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Profile Photo (Logo) Overlapping
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: OptimizedNetworkImage(
                    imageUrl: widget.data['img'], // Ideally use a logo field
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data['name'],
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.data['cuisine'],
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        widget.data['rating'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _infoTile(Icons.access_time_rounded, widget.data['time']),
                _verticalDivider(),
                _infoTile(Icons.location_on_rounded, "2.5 km"),
                _verticalDivider(),
                _infoTile(Icons.delivery_dining_rounded, "Free Delivery"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 14,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey[300],
    );
  }

  Widget _infoTile(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFF5200)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildOffersSection() {
    if (_activeRestaurantOffers.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_num_rounded,
                  color: Color(0xFFFF5200),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "Offers for you",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 85,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _activeRestaurantOffers.length,
              itemBuilder: (context, index) {
                final offer = _activeRestaurantOffers[index];
                final title = (offer['title'] ?? '').toString();
                final val = offer['discountValue'];
                final type =
                    offer['discountType'] == 'percentage' ||
                        offer['discountType'] == 'percent'
                    ? '%'
                    : '₹';
                String discount = "";
                if (val != null) {
                  discount = type == '%' ? '$val% OFF' : 'FLAT ₹$val OFF';
                }

                return Container(
                  width: 210,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Semi-circles for ticket look
                        Positioned(
                          left: -6,
                          top: 28,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.orange.shade100),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -6,
                          top: 28,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.orange.shade100),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 12, 16, 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_offer_rounded,
                                  color: Color(0xFFFF5200),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (title.isNotEmpty)
                                      Text(
                                        title.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFFFF5200),
                                          letterSpacing: 0.8,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (discount.isNotEmpty)
                                      Text(
                                        discount,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF065F46),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Text(
          "Popular Menu",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menuItems')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildMenuShimmer(),
                childCount: 3,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text("No items found")),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final foodData = {
                'id': doc.id,
                'vendorId': widget.restaurantId,
                'name': data['title'] ?? data['name'] ?? 'Unknown Item',
                'description': data['description'] ?? data['desc'] ?? '',
                'price': data['price'] ?? 0,
                'oldPrice': data['oldPrice'],
                'img': data['imageUrl'] ?? data['img'],
                'rating': data['rating'] ?? 0.0,
                'reviews': data['reviews'] ?? 0,
                'bestseller': data['isBestseller'] == true,
                'veg': data['isVeg'] ?? true,
                // Valid Offer Data from Firestore
                'itemOffer': data['offer'],
                'category': data['category'] ?? 'Other',
                // Fallback Restaurant Offers
                'restaurantOffers': _activeRestaurantOffers,
              };

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FoodItemCard(
                  data: foodData,
                  onAdd: () {
                    final cartController = Get.put(FoodController());
                    final cartItem = {
                      "title": foodData['name'],
                      "desc": foodData['description'],
                      "price": foodData['price'],
                      "oldPrice": foodData['oldPrice'],
                      "time": widget.data['time'],
                      "cal": "350 cal", // Default
                      "tags": [data['category'] ?? "Other"],
                      "rating": foodData['rating'],
                      "imageUrl": foodData['img'],
                      "quantity": 1,
                      "vendorId": widget.restaurantId,
                      "itemOffer": foodData['itemOffer'],
                    };
                    cartController.addToCart(cartItem);
                  },
                ),
              );
            }, childCount: snapshot.data!.docs.length),
          ),
        );
      },
    );
  }

  Widget _buildMenuShimmer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 18, width: 140, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(height: 12, width: 100, color: Colors.white),
                    const SizedBox(height: 12),
                    Container(height: 18, width: 60, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
