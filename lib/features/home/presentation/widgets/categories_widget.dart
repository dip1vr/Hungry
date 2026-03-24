import 'package:flutter/material.dart';
import 'package:hungry/shared/widgets/optimized_network_image.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Pizza',
        'img':
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&q=80',
      },
      {
        'name': 'Burger',
        'img':
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&q=80',
      },
      {
        'name': 'Biryani',
        'img':
            'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=200&q=80',
      },
      {
        'name': 'Healthy',
        'img':
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200&q=80',
      },
      {
        'name': 'Dessert',
        'img':
            'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=200&q=80',
      },
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: OptimizedNetworkImage(
                      imageUrl: categories[index]['img']!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      memCacheWidth: 200, // Small size for thumbnails
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  categories[index]['name']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
