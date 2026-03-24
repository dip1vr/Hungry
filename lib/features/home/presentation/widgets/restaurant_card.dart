import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/shared/widgets/optimized_network_image.dart';
import 'package:hungry/features/profile/presentation/controllers/favorites_controller.dart';
import 'package:hungry/features/home/presentation/pages/restaurant_details_page.dart';

class RestaurantCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String restaurantId;

  const RestaurantCard({
    super.key,
    required this.data,
    required this.restaurantId,
  });

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  final FavoritesController favoritesController = Get.put(
    FavoritesController(),
  );

  List<String> _activeOffers = [];
  int _currentOfferIndex = 0;
  Timer? _offerTimer;
  StreamSubscription? _offerSubscription;

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  void _fetchOffers() {
    // Listen to the offers sub-collection
    _offerSubscription = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('offers')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;

          final now = DateTime.now();
          final List<String> loadedOffers = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data['startDate'] != null && data['endDate'] != null) {
              final start = (data['startDate'] as Timestamp).toDate();
              final end = (data['endDate'] as Timestamp).toDate();

              if (now.isAfter(start) && now.isBefore(end)) {
                // Prefer title for the badge text
                final title = data['title']?.toString() ?? '';
                if (title.isNotEmpty) {
                  loadedOffers.add(title);
                }
              }
            }
          }

          setState(() {
            _activeOffers = loadedOffers;
            if (_activeOffers.isNotEmpty) {
              _currentOfferIndex = 0;
              _startOfferCycle();
            } else {
              _activeOffers = [];
              _stopOfferCycle();
            }
          });
        });
  }

  void _startOfferCycle() {
    _stopOfferCycle();
    if (_activeOffers.length > 1) {
      _offerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _currentOfferIndex = (_currentOfferIndex + 1) % _activeOffers.length;
        });
      });
    }
  }

  void _stopOfferCycle() {
    _offerTimer?.cancel();
    _offerTimer = null;
  }

  @override
  void dispose() {
    _stopOfferCycle();
    _offerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => RestaurantDetailsPage(
            data: widget.data,
            restaurantId: widget.restaurantId,
          ),
        );
      },
      child: Container(
        width: 300,
        margin: EdgeInsets.only(right: 16, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: OptimizedNetworkImage(
                    imageUrl: (widget.data['img'] ?? '').toString(),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: 600,
                  ),
                ),

                // Badges Column (Left)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FEATURED BADGE
                      if (widget.data['featured'] == true)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              const Text(
                                "Featured",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // OFFER BADGE (Dynamic)
                      if (_activeOffers.isNotEmpty)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.2),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                          child: Container(
                            key: ValueKey<String>(
                              _activeOffers[_currentOfferIndex],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF1E5EFF),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _activeOffers[_currentOfferIndex],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Rating Badge (Right)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.data['rating'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME + FAST
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.data['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.data['fast'] == true)
                        Text(
                          "⚡Fast",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 4),

                  // CUISINE TEXT
                  Text(
                    widget.data['cuisine'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 12),

                  // PILLS ROW
                  if (widget.data['tags'] != null &&
                      (widget.data['tags'] as List).isNotEmpty)
                    Row(
                      children: (widget.data['tags'] as List).map<Widget>((
                        tag,
                      ) {
                        return Container(
                          margin: EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  SizedBox(height: 12),

                  // TIME + HEART
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey[600],
                            size: 16.0,
                          ),
                          SizedBox(width: 6),
                          Text(
                            widget.data['time'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Live Favorite Heart
                      Obx(() {
                        bool isFav = favoritesController.isFavorite(
                          widget.restaurantId,
                        );
                        return GestureDetector(
                          behavior: HitTestBehavior
                              .translucent, // Ensure tap is caught
                          onTap: () {
                            print(
                              "Heart icon tapped for ${widget.restaurantId}",
                            );
                            favoritesController.toggleFavorite(
                              widget.restaurantId,
                              widget.data,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFav
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey[400],
                              size: 22.0,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
