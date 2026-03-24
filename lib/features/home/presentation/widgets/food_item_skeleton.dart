import 'package:flutter/material.dart';
import 'package:hungry/shared/widgets/shimmer_skeleton.dart';

class FoodItemSkeleton extends StatelessWidget {
  const FoodItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
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
      child: Row(
        children: [
          // Image Skeleton
          Container(
            width: 130,
            height: 130,
            padding: EdgeInsets.all(12),
            child: ShimmerSkeleton(width: 130, height: 130, borderRadius: 20),
          ),

          // Content Skeleton
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerSkeleton(width: 140, height: 20, borderRadius: 6),
                      SizedBox(height: 10),
                      ShimmerSkeleton(width: 180, height: 12, borderRadius: 4),
                      SizedBox(height: 6),
                      ShimmerSkeleton(width: 100, height: 12, borderRadius: 4),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerSkeleton(width: 60, height: 20, borderRadius: 6),
                      ShimmerSkeleton(width: 70, height: 32, borderRadius: 30),
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
