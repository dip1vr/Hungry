import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/core/services/gemini_service.dart';
import 'package:hungry/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:hungry/features/home/presentation/widgets/combo_card.dart';

class MoodCombosPage extends StatefulWidget {
  final Map<String, dynamic> moodData;

  const MoodCombosPage({super.key, required this.moodData});

  @override
  State<MoodCombosPage> createState() => _MoodCombosPageState();
}

class _MoodCombosPageState extends State<MoodCombosPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> generatedCombos = [];

  // Use a Get variable or similar to access global controllers if needed
  // For now we'll fetch explicitly or pretend to fetch from DashboardController

  @override
  void initState() {
    super.initState();
    _generateMoodCombos();
  }

  Future<void> _generateMoodCombos() async {
    setState(() => isLoading = true);

    // DEBUG: Force refresh GeminiService to ensure new code is used
    if (Get.isRegistered<GeminiService>()) {
      Get.delete<GeminiService>();
    }
    Get.put(GeminiService());

    // 1. Get available items
    final dashboardController = Get.find<DashboardController>();
    final itemsDocs = dashboardController.recommendedItems;

    debugPrint("MoodCombos: Dashboard has ${itemsDocs.length} items");

    // Convert to List<Map<String, dynamic>> for category checking
    List<Map<String, dynamic>> availableItems = itemsDocs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    // REMOVED FALLBACK: We rely on database items only.

    try {
      // 2. Call AI
      final moodTitle = widget.moodData['title'] as String;
      debugPrint(
        "MoodCombos: Calling Gemini for $moodTitle with ${availableItems.length} items",
      );

      final result = await GeminiService.to.generateCombos(
        moodTitle,
        availableItems,
      );

      debugPrint("MoodCombos: Gemini returned ${result.length} combos");

      // 3. Enrich result
      final enrichedCombos = result.map((combo) {
        final comboItemsNames = List<String>.from(combo['items'] ?? []);
        final List<Map<String, String>> fullItems = [];

        for (var name in comboItemsNames) {
          final doc = itemsDocs.firstWhereOrNull(
            (d) =>
                (d.data() as Map<String, dynamic>)['name']
                    .toString()
                    .toLowerCase() ==
                name.toLowerCase(),
          );

          if (doc != null) {
            final data = doc.data() as Map<String, dynamic>;
            fullItems.add({
              'name': name,
              'image':
                  data['imageUrl'] ??
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
            });
          } else {
            fullItems.add({
              'name': name,
              'image':
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
            });
          }
        }

        return {...combo, 'items': fullItems};
      }).toList();

      if (mounted) {
        setState(() {
          generatedCombos = enrichedCombos;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("MoodCombos: Error generating combos: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract mood details
    final String title = widget.moodData['title'] as String;
    final String emoji = widget.moodData['emoji'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "$emoji $title",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "AI Curated Combos",
              style: TextStyle(
                color: Colors.deepPurple[400],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : generatedCombos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cookie_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No items match the '$title' mood.\nWe need more food categories!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _generateMoodCombos,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              itemCount: generatedCombos.length,
              itemBuilder: (context, index) {
                final combo = generatedCombos[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ComboCard(
                    title: combo['title'] ?? 'Combo',
                    subtitle: combo['subtitle'] ?? 'Delicious Mix',
                    price: (combo['price'] as num?)?.toDouble() ?? 0.0,
                    oldPrice: (combo['oldPrice'] as num?)?.toDouble(),
                    items: List<Map<String, String>>.from(combo['items']),
                    onAdd: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${combo['title']} added to bucket!"),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
