import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/orders/presentation/controllers/food_controller.dart';
import 'package:hungry/features/cart/cart_page.dart';
import 'dart:ui';

class ModernCartButton extends StatefulWidget {
  const ModernCartButton({super.key});

  @override
  State<ModernCartButton> createState() => _ModernCartButtonState();
}

class _ModernCartButtonState extends State<ModernCartButton>
    with SingleTickerProviderStateMixin {
  final FoodController controller = Get.find<FoodController>();
  late AnimationController _borderController;
  int _prevItemCount = 0;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Smooth 1s Draw
    );

    // Listen to changes
    ever(controller.cartItems, (items) {
      // Trigger on ANY addition (if count increases)
      if (items.length > _prevItemCount) {
        _borderController.forward(from: 0.0);
      }
      _prevItemCount = items.length;
    });
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cartItems.isEmpty) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.to(() => CartPage()),
        child: Container(
          // Margin to position it in the Stack (Positioned handles the rest, but we keep this for safety/sizing)
          // Actually, since we are doing custom painting, we need a defined size or let children define it.
          // Container margin handles the separation from edges if inside a stack without precise positioned constraints.
          margin: const EdgeInsets.only(bottom: 1, right: 16),
          child: AnimatedBuilder(
            animation: _borderController,
            builder: (context, child) {
              return CustomPaint(
                painter: CartBorderPainter(progress: _borderController.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  // We removed the decoration here because the Painter draws the background!!
                  // Otherwise double background.
                  // Wait, if Painter draws background, the child content sits on top.
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${controller.cartItems.length} Item${controller.cartItems.length > 1 ? 's' : ''}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "₹${controller.totalPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "View Cart",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class CartBorderPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  CartBorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(30),
    );

    // 1. Draw Background (Green)
    final Paint bgPaint = Paint()
      ..color =
          const Color(0xFF4CAF50) // Brand Green
      ..style = PaintingStyle.fill;

    // Add Shadow manually since we lost Container decoration
    final Path shadowPath = Path()..addRRect(rRect);
    canvas.drawShadow(shadowPath, Colors.green.withOpacity(0.4), 8.0, true);

    canvas.drawRRect(rRect, bgPaint);

    // 2. Draw Animating Border
    if (progress > 0) {
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final Path borderPath = Path()..addRRect(rRect);

      // Extract metrics
      final PathMetrics metrics = borderPath.computeMetrics();
      for (final PathMetric metric in metrics) {
        // Calculate length to draw
        final double length = metric.length * progress;
        // Extract sub-path
        final Path extractPath = metric.extractPath(0.0, length);
        canvas.drawPath(extractPath, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CartBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
