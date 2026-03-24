import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/home/presentation/pages/mood_combos_page.dart';
import 'package:hungry/shared/widgets/optimized_network_image.dart';

class MoodSection extends StatelessWidget {
  const MoodSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Enhanced Data Structure for Moods
    final moods = [
      {
        'title': 'PARTY',
        'subtitle': 'Mode',
        'emoji': '🎉',
        'color1': const Color(0xFF8E2DE2),
        'color2': const Color(0xFF4A00E0),
        'images': [
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80', // Pizza
          'https://images.unsplash.com/photo-1541283091509-33d7bb6a98b4?w=400&q=80', // Burger
          'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=400&q=80', // Coke
          'https://images.unsplash.com/photo-1572177215152-32f247303126?w=400&q=80', // Donuts
        ],
      },
      {
        'title': 'MOVIE',
        'subtitle': 'Night',
        'emoji': '🍿',
        'color1': const Color(0xFFEE0979),
        'color2': const Color(0xFFFF6A00),
        'images': [
          'https://images.unsplash.com/photo-1572177215152-32f247303126?w=400&q=80', // Popcorn
          'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=400&q=80', // Coke
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80', // Burger
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&q=80', // Juice
        ],
      },
      {
        'title': 'SAD',
        'subtitle': 'Comfort',
        'emoji': '☕️',
        'color1': const Color(0xFF00c6ff),
        'color2': const Color(0xFF0072ff),
        'images': [
          'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&q=80', // Ice Cream
          'https://images.unsplash.com/photo-1577805947697-89e18249d767?w=400&q=80', // Milkshake
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80', // Pizza
          'https://images.unsplash.com/photo-1572177215152-32f247303126?w=400&q=80', // Donuts
        ],
      },
      {
        'title': 'SNACK',
        'subtitle': 'Time',
        'emoji': '🍟',
        'color1': const Color(0xFFF7971E),
        'color2': const Color(0xFFFFD200),
        'images': [
          'https://images.unsplash.com/photo-1550547660-d9450f859349?w=400&q=80', // Burger
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&q=80', // Juice
          'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=400&q=80', // Coke
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80', // Burger
        ],
      },
      {
        'title': 'WORK',
        'subtitle': 'Focus',
        'emoji': '☕',
        'color1': const Color(0xFF56ab2f),
        'color2': const Color(0xFFa8e063),
        'images': [
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80', // Salad
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&q=80', // Juice
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80', // Pizza
          'https://images.unsplash.com/photo-1621303837174-89787a7d4729?w=400&q=80', // Coke
        ],
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
                  const SizedBox(height: 4),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tune, size: 20, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              final images = mood['images'] as List<String>;
              final color1 = mood['color1'] as Color;
              final color2 = mood['color2'] as Color;

              return GestureDetector(
                onTap: () {
                  Get.to(() => MoodCombosPage(moodData: moods[index]));
                },
                child: RepaintBoundary(
                  child: Container(
                    width: 170, // Slightly wider for grid
                    margin: const EdgeInsets.only(right: 16),
                    child: Stack(
                      children: [
                        // 1. Grid Background
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color1.withValues(alpha: 0.1),
                                color2.withValues(alpha: 0.1),
                              ],
                            ),
                            // shadow
                            boxShadow: [
                              BoxShadow(
                                color: color1.withValues(alpha: 0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Stack(
                              children: [
                                // The Dynamic Grid (5 Unique Styles)
                                _buildUniqueGrid(images, index),

                                // Gradient Overlay for Text Readability - LIGHTER
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.transparent,
                                        color1.withValues(alpha: 0.3),
                                        color2.withValues(alpha: 0.7),
                                      ],
                                      stops: const [0.0, 0.5, 0.8, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 2. Content (Text & Emoji)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Floating Emoji
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  mood['emoji']! as String,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const Spacer(),
                              // Big Vertical Text
                              Text(
                                mood['title']! as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 1,
                                  height: 0.9,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                mood['subtitle']! as String,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUniqueGrid(List<String> images, int index) {
    const double spacing = 2;
    // Ensure we always have 4 images for the styles (mock if less)
    final displayImages = [...images];
    while (displayImages.length < 4) {
      displayImages.add(images[0]);
    }

    // 5 Unique Layouts based on index (0-4)
    switch (index % 5) {
      // Layout 1: Left Big Vertical, 2 Right
      case 0:
        return Row(
          children: [
            Expanded(flex: 3, child: _buildGridImage(displayImages[0])),
            const SizedBox(width: spacing),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: _buildGridImage(displayImages[1])),
                  const SizedBox(height: spacing),
                  Expanded(child: _buildGridImage(displayImages[2])),
                ],
              ),
            ),
          ],
        );

      // Layout 2: Top Big Horizontal, 3 Small Row (NO 2x2 GRID)
      case 1:
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: _buildGridImage(displayImages[2]), // Rotate image usage
            ),
            const SizedBox(height: spacing),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(child: _buildGridImage(displayImages[0])),
                  const SizedBox(width: spacing),
                  Expanded(child: _buildGridImage(displayImages[1])),
                  const SizedBox(width: spacing),
                  Expanded(child: _buildGridImage(displayImages[3])),
                ],
              ),
            ),
          ],
        );

      // Layout 3: Right Big Vertical (Mirror of 1)
      case 2:
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: _buildGridImage(displayImages[1])),
                  const SizedBox(height: spacing),
                  Expanded(child: _buildGridImage(displayImages[2])),
                ],
              ),
            ),
            const SizedBox(width: spacing),
            Expanded(flex: 3, child: _buildGridImage(displayImages[0])),
          ],
        );

      // Layout 4: Bottom Big Horizontal, 3 Top Row (Mirror of 2)
      case 3:
        return Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(child: _buildGridImage(displayImages[0])),
                  const SizedBox(width: spacing),
                  Expanded(child: _buildGridImage(displayImages[1])),
                  const SizedBox(width: spacing),
                  Expanded(child: _buildGridImage(displayImages[3])),
                ],
              ),
            ),
            const SizedBox(height: spacing),
            Expanded(flex: 3, child: _buildGridImage(displayImages[2])),
          ],
        );

      // Layout 5: 3 Vertical Stripes (Unique)
      default:
        return Row(
          children: [
            Expanded(child: _buildGridImage(displayImages[0])),
            const SizedBox(width: spacing),
            Expanded(flex: 2, child: _buildGridImage(displayImages[1])),
            const SizedBox(width: spacing),
            Expanded(child: _buildGridImage(displayImages[2])),
          ],
        );
    }
  }

  Widget _buildGridImage(String url) {
    return OptimizedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
