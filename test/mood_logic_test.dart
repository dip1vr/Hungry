import 'package:flutter_test/flutter_test.dart';
import 'package:hungry/core/services/gemini_service.dart';

void main() {
  group('GeminiService Mood Logic', () {
    final service = GeminiService();

    // Mock Items
    final pizzaItem = {
      'name': 'Cheese Pizza',
      'category': 'Pizza',
      'price': 1200,
    };
    final burgerItem = {
      'name': 'Classic Burger',
      'category': 'Burger',
      'price': 500,
    };
    final coffeeItem = {'name': 'Latte', 'category': 'Coffee', 'price': 250};
    final saladItem = {
      'name': 'Ceasar Salad',
      'category': 'Salad',
      'price': 400,
    };
    final sushiItem = {
      'name': 'Salmon Roll',
      'category': 'Sushi',
      'price': 800,
    };

    final allItems = [pizzaItem, burgerItem, coffeeItem, saladItem, sushiItem];

    test('PARTY mood should include Pizza and Burger but NOT Coffee', () async {
      final combos = await service.generateCombos('PARTY', allItems);

      // We expect some result because we have Pizza and Burger (length 2 -> "Quick Fix")
      expect(combos.isNotEmpty, true);

      for (var combo in combos) {
        final items = combo['items'] as List<String>;
        for (var itemName in items) {
          // Should be Pizza or Burger
          expect(
            ['Cheese Pizza', 'Classic Burger'].contains(itemName),
            true,
            reason: '$itemName should be in PARTY combo',
          );
          // Should NOT be Coffee
          expect(itemName, isNot('Latte'));
        }
      }
    });

    test('WORK mood should include Coffee and Salad', () async {
      final combos = await service.generateCombos('WORK', allItems);
      expect(combos.isNotEmpty, true);

      for (var combo in combos) {
        final items = combo['items'] as List<String>;
        for (var itemName in items) {
          expect(['Latte', 'Ceasar Salad'].contains(itemName), true);
        }
      }
    });

    test(
      'SAD mood should verify categories (assuming Pizza/Burger/Coffee might not be in SAD)',
      () async {
        // SAD categories: Dessert, Comfort Food, Ice Cream, Chocolate, Cake, Beverages, Pizza
        // Pizza IS in SAD in strict map.

        final combos = await service.generateCombos('SAD', allItems);
        // Should match Pizza only from our list?
        // Pizza is in SAD. Burger is NOT in SAD map ?
        // Let's check map: SAD -> [Dessert, Comfort Food, Ice Cream, Chocolate, Cake, Beverages, Pizza]

        // So 'Cheese Pizza' (Category: Pizza) should be there.
        // 'Classic Burger' (Category: Burger) -> Burger is NOT in SAD list.

        for (var combo in combos) {
          final items = combo['items'] as List<String>;
          for (var itemName in items) {
            expect(itemName, 'Cheese Pizza');
            expect(itemName, isNot('Classic Burger'));
          }
        }
      },
    );

    test('Unknown Mood or No Matches should return empty', () async {
      final combos = await service.generateCombos('UNKNOWN_MOOD', allItems);
      expect(combos, isEmpty);

      // Create empty items list
      final emptyCombos = await service.generateCombos('PARTY', []);
      expect(emptyCombos, isEmpty);
    });
  });
}
