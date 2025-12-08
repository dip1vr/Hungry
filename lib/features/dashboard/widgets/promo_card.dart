import 'package:flutter/material.dart';
import 'package:hungry/common/widgets/optimized_network_image.dart';

class PromoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PromoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<Color> bgColors = data['bg_colors'] as List<Color>;
    Color accentColor = data['accent'] as Color;
    bool isDark = data['is_dark'] as bool;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgColors,
        ),
        boxShadow: [
          BoxShadow(
            color: bgColors.last.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Doodle/Pattern
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.auto_awesome,
              size: 150,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),

          Row(
            children: [
              // LEFT SIDE: Text Content (55%)
              Expanded(
                flex: 55,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 12, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          "🔥 ${data['code']}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Spacer(),
                      // Title
                      Text(
                        data['title'] as String,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Subtitle
                      Text(
                        data['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                      Spacer(),
                      // Button
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Order Now",
                              style: TextStyle(
                                color: isDark ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // RIGHT SIDE: Image (45%)
              Expanded(
                flex: 45,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow behind image
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Image
                    Transform.rotate(
                      angle: 0.1, // Slight tilt for dynamism
                      child: Container(
                        margin: EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: Offset(5, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: OptimizedNetworkImage(
                            imageUrl: data['image'] as String,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
