import 'package:flutter/material.dart';
import 'package:hungry/shared/widgets/shimmer_skeleton.dart';

class RestaurantSkeleton extends StatelessWidget {
  const RestaurantSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Skeleton
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: ShimmerSkeleton(width: double.infinity, height: 180),
          ),

          // Content Skeleton
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Fast badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerSkeleton(width: 150, height: 20, borderRadius: 6),
                    ShimmerSkeleton(width: 40, height: 16, borderRadius: 4),
                  ],
                ),
                const SizedBox(height: 8),

                // Cuisine
                ShimmerSkeleton(width: 100, height: 14, borderRadius: 4),
                const SizedBox(height: 12),

                // Tags pills
                Row(
                  children: [
                    ShimmerSkeleton(width: 60, height: 24, borderRadius: 12),
                    const SizedBox(width: 8),
                    ShimmerSkeleton(width: 80, height: 24, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 12),

                // Time and Heart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ShimmerSkeleton(width: 16, height: 16, borderRadius: 8),
                        const SizedBox(width: 6),
                        ShimmerSkeleton(width: 50, height: 14, borderRadius: 4),
                      ],
                    ),
                    ShimmerSkeleton(width: 24, height: 24, borderRadius: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
