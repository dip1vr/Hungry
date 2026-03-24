import 'package:flutter/material.dart';
import 'package:hungry/shared/widgets/optimized_network_image.dart';

class ModernMoodCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> colors;
  final List<Map<String, String>> items;
  final double price;
  final double? oldPrice;
  final VoidCallback onAdd;
  final VoidCallback onLike;
  final VoidCallback onTap;
  final bool isCustom;

  const ModernMoodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colors,
    required this.items,
    required this.price,
    this.oldPrice,
    required this.onAdd,
    required this.onLike,
    required this.onTap,
    this.isCustom = false,
  });

  @override
  State<ModernMoodCard> createState() => _ModernMoodCardState();
}

class _ModernMoodCardState extends State<ModernMoodCard> {
  // Track removed item INDICES for this specific card
  final Set<int> _removedIndices = {};

  void _toggleItem(int index) {
    setState(() {
      if (_removedIndices.contains(index)) {
        _removedIndices.remove(index);
      } else {
        _removedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Matches FoodItemCard Base Style
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title, Subtitle, Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${widget.price.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.green, // Brand Green for Price
                          ),
                        ),
                        if (widget.oldPrice != null)
                          Text(
                            "₹${widget.oldPrice!.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                ),

                // Interactive Item List
                if (widget.items.isNotEmpty)
                  ...List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    return _buildListItem(item, index);
                  }),

                // Custom Empty View
                if (widget.isCustom && widget.items.isEmpty)
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Text(
                      "Start building your dream combo",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Footer: Add Button (Full Width) & Like
                Row(
                  children: [
                    // Like Button (Subtle)
                    Material(
                      color: Colors.grey[50], // Very light grey
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: widget.onLike,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add Button (Primary)
                    Expanded(
                      child: Material(
                        color: Colors.black, // Premium Black
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: widget.onAdd,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: const Text(
                              "ADD TO CART",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildListItem(Map<String, String> item, int index) {
    final bool isRemoved = _removedIndices.contains(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isRemoved ? 0.4 : 1.0, // Fade out if removed
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: OptimizedNetworkImage(
                imageUrl: item['image'] ?? '',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            // Name
            Expanded(
              child: Text(
                item['name'] ?? 'Unknown Item',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  decoration: isRemoved
                      ? TextDecoration.lineThrough
                      : null, // Strike through if removed
                ),
              ),
            ),

            // Interactive Toggle Button
            GestureDetector(
              onTap: () => _toggleItem(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6), // Slightly larger touch area
                decoration: BoxDecoration(
                  color: isRemoved
                      ? Colors.grey[200]
                      : Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRemoved
                      ? Icons.add
                      : Icons.check, // "Add" to active, "Check" if active
                  size: 16,
                  color: isRemoved ? Colors.grey : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
