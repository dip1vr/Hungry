import 'package:flutter/material.dart';
import 'package:hungry/common/widgets/shimmer_skeleton.dart';

class MoodSection extends StatelessWidget {
  const MoodSection({super.key});

  @override
  Widget build(BuildContext context) {
    final moods = [
      {
        'title': 'PARTY',
        'subtitle': 'Mode',
        'emoji': '🎉',
        'color1': Color(0xFF8E2DE2),
        'color2': Color(0xFF4A00E0),
        'image':
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&q=80',
      },
      {
        'title': 'MOVIE',
        'subtitle': 'Night',
        'emoji': '🍿',
        'color1': Color(0xFFEE0979),
        'color2': Color(0xFFFF6A00),
        'image':
            'https://images.unsplash.com/photo-1572177215152-32f247303126?w=500&q=80',
      },
      {
        'title': 'SAD',
        'subtitle': 'Comfort',
        'emoji': '☕️',
        'color1': Color(0xFF00c6ff),
        'color2': Color(0xFF0072ff),
        'image':
            'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500&q=80',
      },
      {
        'title': 'SNACK',
        'subtitle': 'Time',
        'emoji': '🍟',
        'color1': Color(0xFFF7971E),
        'color2': Color(0xFFFFD200),
        'image':
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
      },
      {
        'title': 'WORK',
        'subtitle': 'Focus',
        'emoji': '☕',
        'color1': Color(0xFF56ab2f),
        'color2': Color(0xFFa8e063),
        'image':
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500&q=80',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    "Food for every feeling",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.tune, size: 20, color: Colors.black87),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: Container(
                  width: 160,
                  margin: EdgeInsets.only(right: 16),
                  child: Stack(
                    children: [
                      // Base Container with Gradient & Image
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (moods[index]['color1'] as Color),
                              (moods[index]['color2'] as Color),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (moods[index]['color1'] as Color)
                                  .withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 1. Crystal Clear Image (No Tint)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.network(
                                moods[index]['image']! as String,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return ShimmerSkeleton(
                                        width: double.infinity,
                                        height: double.infinity,
                                        borderRadius: 0,
                                      );
                                    },
                              ),
                            ),
                            // 2. Subtle Moody Gradient Overlay (Bottom Only)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    (moods[index]['color1'] as Color)
                                        .withValues(alpha: 0.0),
                                    (moods[index]['color1'] as Color)
                                        .withValues(alpha: 0.8),
                                    (moods[index]['color2'] as Color)
                                        .withValues(alpha: 0.95),
                                  ],
                                  stops: [0.0, 0.4, 0.75, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Floating Emoji
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                moods[index]['emoji']! as String,
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                            Spacer(),
                            // Big Vertical Text
                            Text(
                              moods[index]['title']! as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              moods[index]['subtitle']! as String,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2,
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
      ],
    );
  }
}
