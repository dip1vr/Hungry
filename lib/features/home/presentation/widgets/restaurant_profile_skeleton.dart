import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantProfileSkeleton extends StatelessWidget {
  const RestaurantProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Area
                  Container(
                    height: 240,
                    width: double.infinity,
                    color: Colors.white,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Image Placeholder (Overlapping)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            transform: Matrix4.translationValues(0, -35, 0),
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),

                        // Name and Rating Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 28,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              height: 28,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Cuisine
                        Container(
                          height: 16,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Info Icons Row (Time, Distance, Delivery)
                        Row(
                          children: [
                            _shimmerInfoTile(80),
                            _verticalDivider(),
                            _shimmerInfoTile(60),
                            _verticalDivider(),
                            _shimmerInfoTile(90),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Section Title: Offers
                        _shimmerBar(120, 20),
                        const SizedBox(height: 12),

                        // Offers Placeholders
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 2,
                            itemBuilder: (_, __) => Container(
                              width: 180,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Section Title: Menu
                        _shimmerBar(150, 24),
                        const SizedBox(height: 16),

                        // Menu Items List
                        ...List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _shimmerBar(140, 16),
                                        const SizedBox(height: 8),
                                        _shimmerBar(double.infinity, 12),
                                        const SizedBox(height: 4),
                                        _shimmerBar(100, 12),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _shimmerBar(60, 16),
                                            Container(
                                              width: 60,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Back Button (Static)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: Container(
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
          ),
        ],
      ),
    );
  }

  Widget _shimmerInfoTile(double width) {
    return Row(
      children: [
        _shimmerCircle(16),
        const SizedBox(width: 6),
        Container(width: width, height: 12, color: Colors.white),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 14,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white,
    );
  }

  Widget _shimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _shimmerBar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
