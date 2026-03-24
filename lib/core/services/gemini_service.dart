import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Replaces the actual Gemini AI with a local "Smart Algorithm"
/// that mimics intelligence by matching keywords to moods.
class GeminiService extends GetxService {
  static GeminiService get to => Get.find();

  // Strict Category mappings for different moods
  // These must match the 'category' field in your Firestore items
  final Map<String, List<String>> _moodCategories = {
    'PARTY': [
      'Fast Food',
      'Pizza',
      'Burger',
      'Wings',
      'Beverages',
      'Snacks',
      'Tacos',
      'Nachos',
    ],
    'MOVIE': [
      'Snacks',
      'Popcorn',
      'Chips',
      'Beverages',
      'Fast Food',
      'Burger',
      'Sandwich',
      'Dessert',
    ],
    'WORK': [
      'Coffee',
      'Tea',
      'Sandwich',
      'Salad',
      'Wraps',
      'Bakery',
      'Juice',
      'Healthy',
    ],
    'DATE': [
      'Fine Dining',
      'Pasta',
      'Steak',
      'Dessert',
      'Cake',
      'Beverages',
      'Sushi',
      'Asian',
      'Ice Cream',
    ],
    'COMFORT': [
      'Comfort Food',
      'Dessert',
      'Ice Cream',
      'Pizza',
      'Burger',
      'Chinese',
      'Indian',
      'Biryani',
      'Soup',
    ],
    'HEALTHY': [
      'Salad',
      'Healthy',
      'Juice',
      'Fruit',
      'Smoothie',
      'Yogurt',
      'Soup',
      'Grill',
    ],
    'SAD': [
      'Dessert',
      'Comfort Food',
      'Ice Cream',
      'Chocolate',
      'Cake',
      'Beverages',
      'Pizza',
    ],
    'SNACK': ['Snacks', 'Fast Food', 'Beverages', 'Bakery', 'Dessert'],
  };

  /// Generates combos based STRICTLY on categories.
  /// Returns empty list if no items match the mood's categories.
  Future<List<Map<String, dynamic>>> generateCombos(
    String mood,
    List<Map<String, dynamic>> availableItems,
  ) async {
    // Simulate thinking time (0.5s) for "AI feel"
    await Future.delayed(const Duration(milliseconds: 600));

    final String normalizedMood = mood.toUpperCase();
    final List<String> targetCategories = _moodCategories[normalizedMood] ?? [];

    if (targetCategories.isEmpty) {
      // If mood hasn't been defined in our map, return empty or generic?
      // User requested strict category dependency, so we return empty.
      return [];
    }

    // 1. Filter items that match the mood's categories
    final List<Map<String, dynamic>> matchingItems = availableItems.where((
      item,
    ) {
      final itemCategory = item['category']?.toString();
      if (itemCategory == null) return false;

      // Check if item's category is one of the target categories for this mood
      // Case-insensitive match for robustness
      return targetCategories.any(
        (cat) => cat.toLowerCase() == itemCategory.toLowerCase(),
      );
    }).toList();

    // STRICT: If no matching items, do NOT return combos.
    if (matchingItems.isEmpty) {
      return [];
    }

    // 2. Generate combos from valid matching items
    // We try to make different combinations if we have enough items.

    final List<Map<String, dynamic>> combos = [];

    // Combo 1: The Feast (3-4 items)
    if (matchingItems.length >= 3) {
      combos.add(
        _createCombo(
          "Ultimate $mood Feast",
          "Perfect for the mood",
          matchingItems,
          3,
        ),
      );
    } else if (matchingItems.isNotEmpty) {
      // If we have few items, just make a smaller feast
      combos.add(
        _createCombo(
          "Ultimate $mood Feast",
          "Perfect for the mood",
          matchingItems,
          matchingItems.length,
        ),
      );
    }

    // Combo 2: Quick Fix (2 items)
    if (matchingItems.length >= 2) {
      combos.add(
        _createCombo("$mood Quick Fix", "Light & Tasty", matchingItems, 2),
      );
    }

    // Combo 3: Special (2 items, different shuffle implicitly handled by _createCombo)
    if (matchingItems.length >= 2) {
      // We'll only add this if we have enough variety or just to show another option
      // To avoid duplicates if we have very few items, we check size
      if (matchingItems.length > 2) {
        combos.add(
          _createCombo("$mood Special", "Highly Recommended", matchingItems, 2),
        );
      }
    }

    return combos;
  }

  Map<String, dynamic> _createCombo(
    String title,
    String subtitle,
    List<Map<String, dynamic>> sourceItems,
    int itemCount,
  ) {
    final random = Random();
    // Shuffle source to get variety each time
    final shuffled = List<Map<String, dynamic>>.from(sourceItems)..shuffle();
    final selectedItemsMaps = shuffled.take(itemCount).toList();

    final List<String> selectedItemNames = selectedItemsMaps
        .map((m) => m['name'] as String)
        .toList();

    // Calculate mock price based on real item prices if available
    double rawPrice = 0;
    for (var item in selectedItemsMaps) {
      // Try to get price from item, fallback to random if missing/parse error
      double itemPrice = 0;
      if (item['price'] != null) {
        itemPrice = double.tryParse(item['price'].toString()) ?? 0;
      }
      if (itemPrice == 0) {
        itemPrice = 150.0 + random.nextInt(200);
      }
      rawPrice += itemPrice;
    }

    final discountedPrice = (rawPrice * 0.85).round().toDouble(); // 15% off

    return {
      "title": title,
      "subtitle": subtitle,
      "items":
          selectedItemNames, // We still return names for now as the verified page rebuilds them, or we could return full objects if needed.
      // But looking at UI code, it enriches based on names.
      // Ideally we pass full objects back to avoid re-lookup, but to keep changes minimal strictly to logic first:
      "price": discountedPrice,
      "oldPrice": rawPrice,
    };
  }
}
