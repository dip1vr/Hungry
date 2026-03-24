import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shimmer
          _buildShimmerBlock(height: 50, width: double.infinity, radius: 12),
          const SizedBox(height: 16),
          // Search Bar Shimmer
          _buildShimmerBlock(height: 50, width: double.infinity, radius: 25),
          const SizedBox(height: 20),
          // Promo Carousel Shimmer
          _buildShimmerBlock(height: 160, width: double.infinity, radius: 16),
          const SizedBox(height: 24),
          // Section Title
          _buildShimmerBlock(height: 20, width: 150),
          const SizedBox(height: 16),
          // Categories Shimmer (Horizontal)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) => Column(
                children: [
                  _buildShimmerBlock(
                    height: 70,
                    width: 70,
                    radius: 35,
                  ), // Circle
                  const SizedBox(height: 8),
                  _buildShimmerBlock(height: 12, width: 50),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Featured Restaurants Shimmer
          _buildShimmerBlock(height: 20, width: 180),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBlock(height: 150, width: 280, radius: 16),
                  const SizedBox(height: 10),
                  _buildShimmerBlock(height: 16, width: 200),
                  const SizedBox(height: 6),
                  _buildShimmerBlock(height: 12, width: 150),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBlock({
    required double height,
    required double width,
    double radius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
