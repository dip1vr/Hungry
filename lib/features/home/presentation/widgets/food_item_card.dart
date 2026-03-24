import 'package:flutter/material.dart';
import 'package:hungry/shared/widgets/optimized_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shimmer/shimmer.dart';

class FoodItemCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onAdd;

  // Static cache to store restaurant names and avoid redundant fetches
  static final Map<String, String> _restaurantNameCache = {};
  // Static cache to store restaurant-level offers
  static final Map<String, Map<String, String>> _restaurantOfferCache = {};

  const FoodItemCard({super.key, required this.data, this.onAdd});

  Map<String, String>? _parseOfferMap(Map<String, dynamic> offer) {
    if (offer['isActive'] != true) return null;

    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (offer['startDate'] is Timestamp) {
      start = (offer['startDate'] as Timestamp).toDate();
    }
    if (offer['endDate'] is Timestamp) {
      end = (offer['endDate'] as Timestamp).toDate();
    }

    if (start != null && end != null) {
      if (now.isAfter(start) && now.isBefore(end)) {
        String title = (offer['title'] ?? '').toString();
        String discount = "";

        if (offer['discountValue'] != null && offer['discountType'] != null) {
          final val = offer['discountValue'];
          final type =
              offer['discountType'] == 'percentage' ||
                  offer['discountType'] == 'percent'
              ? '%'
              : '₹';
          if (type == '%') {
            discount = '$val% OFF';
          } else {
            discount = 'FLAT ₹$val OFF';
          }
        }

        if (title.isNotEmpty || discount.isNotEmpty) {
          return {'title': title, 'value': discount};
        }
      }
    }
    return null;
  }

  Map<String, String>? _getDisplayOffer() {
    final rawOffer = data['itemOffer'] ?? data['offer'];
    if (rawOffer != null && rawOffer is Map) {
      return _parseOfferMap(Map<String, dynamic>.from(rawOffer));
    }

    // 2. Check for restaurant offers passed in data (from RestaurantDetailsPage)
    // This part handles fallbacks that are already known/passed
    if (data['restaurantOffers'] != null && data['restaurantOffers'] is List) {
      final List offers = data['restaurantOffers'];
      if (offers.isNotEmpty) {
        // Just take the first one for simplicity, or we could handle them differently
        return {
          'title': offers[0].toString(),
          'value': '', // Passed offers might only have a title string
        };
      }
    }

    return null;
  }

  Future<Map<String, String>?> _fetchRestaurantOffer(String vendorId) async {
    // Check Cache first
    if (_restaurantOfferCache.containsKey(vendorId)) {
      return _restaurantOfferCache[vendorId];
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(vendorId)
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final offerData = snapshot.docs.first.data();
        final parsed = _parseOfferMap(offerData);
        if (parsed != null) {
          _restaurantOfferCache[vendorId] = parsed;
          return parsed;
        }
      }
    } catch (e) {
      debugPrint("Error fetching restaurant offer: $e");
    }

    return null;
  }

  Widget _buildRestaurantBadge(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.store_rounded, size: 14, color: Colors.orange[800]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.orange[900],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.orange.shade100,
        highlightColor: Colors.orange.shade50,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_rounded, size: 14, color: Colors.orange[200]),
            const SizedBox(width: 4),
            Container(
              width: 60,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF6B7280),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildOfferBadge(Map<String, String>? offerMap) {
    if (offerMap == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (offerMap['title']!.isNotEmpty)
            Text(
              offerMap['title']!.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFF5200),
                letterSpacing: 0.5,
              ),
            ),
          if (offerMap['title']!.isNotEmpty && offerMap['value']!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "|",
                style: TextStyle(
                  color: Colors.orange.withOpacity(0.3),
                  fontSize: 10,
                ),
              ),
            ),
          if (offerMap['value']!.isNotEmpty)
            Text(
              offerMap['value']!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF059669),
              ),
            ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return "₹0.0";
    String pStr = price.toString();
    if (pStr.startsWith('₹')) {
      pStr = pStr.substring(1).trim();
    }
    double? val = double.tryParse(pStr);
    if (val == null) return "₹$pStr";
    return "₹${val.toStringAsFixed(1)}";
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String>? offerMap = _getDisplayOffer();
    final String? vendorId = data['vendorId'];
    final String category = (data['category'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Centered vertically
        children: [
          // LEFT: Image Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: OptimizedNetworkImage(
                    imageUrl: (data['img'] ?? '').toString(),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    memCacheWidth: 350,
                  ),
                ),
                if (data['bestseller'] == true)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC107),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        "BESTSELLER",
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // RIGHT: Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row (Restaurant + Category)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (vendorId != null)
                        _restaurantNameCache.containsKey(vendorId)
                            ? _buildRestaurantBadge(
                                _restaurantNameCache[vendorId]!,
                              )
                            : FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('restaurants')
                                    .doc(vendorId)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData &&
                                        snapshot.data!.exists) {
                                      final rData =
                                          snapshot.data!.data()
                                              as Map<String, dynamic>;
                                      final vName =
                                          rData['restaurantName'] ??
                                          'Unknown Vendor';
                                      _restaurantNameCache[vendorId] = vName;
                                      return _buildRestaurantBadge(vName);
                                    }
                                    return _buildRestaurantBadge(
                                      "Unknown Vendor",
                                    );
                                  }
                                  return _buildShimmerBadge();
                                },
                              ),
                      if (category.isNotEmpty) _buildCategoryBadge(category),
                    ],
                  ),

                  // Title
                  Text(
                    (data['name'] ?? 'Unknown Item').toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Description
                  Text(
                    (data['description'] ?? data['desc'] ?? '').toString(),
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Offer Badge (Dedicated row to avoid layout shift and mixing)
                  if (offerMap != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildOfferBadge(offerMap),
                    )
                  else if (vendorId != null)
                    FutureBuilder<Map<String, String>?>(
                      future: _fetchRestaurantOffer(vendorId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildOfferBadge(snapshot.data),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                  // Bottom Row: Price + Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price Row (With Auto-Scaling)
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (data['oldPrice'] != null) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    _formatPrice(data['oldPrice']),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              Text(
                                _formatPrice(data['price']),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Add Button
                      Material(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Add",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
