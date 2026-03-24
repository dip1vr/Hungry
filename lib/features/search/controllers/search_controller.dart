import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlobalSearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<QueryDocumentSnapshot> searchResults =
      <QueryDocumentSnapshot>[].obs;
  final RxList<QueryDocumentSnapshot> recommendedResults =
      <QueryDocumentSnapshot>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;

  final RxString searchType = 'food'.obs; // 'food' or 'restaurant'

  final RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Debounce the search to prevent API spam and flickering
    debounce(searchText, (query) {
      if (query.isNotEmpty) {
        performSearch(query);
      } else {
        searchResults.clear();
        recommendedResults.clear();
        isSearching.value = false;
        isLoading.value = false;
      }
    }, time: const Duration(milliseconds: 500));
  }

  void setSearchType(String type) {
    searchType.value = type;
    // Retrigger search if text exists, without debounce for immediate mode switch
    if (searchController.text.isNotEmpty) {
      performSearch(searchController.text);
    } else {
      searchResults.clear();
      recommendedResults.clear();
    }
  }

  void onSearchChanged(String val) {
    searchText.value = val;
    if (val.isEmpty) {
      searchResults.clear();
      recommendedResults.clear();
      isSearching.value = false;
      isLoading.value = false;
    }
  }

  // Renamed from onSearch to performSearch to distinguish from event handler
  void performSearch(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      recommendedResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    isLoading.value = true;
    recommendedResults.clear(); // Clear old recommendations before new search

    try {
      final formattedQuery = query.toLowerCase().trim();

      if (searchType.value == 'food') {
        // --- FOOD SEARCH ---
        // Fetch all items (Limited to 500 for performance) and filter client-side
        final allItems = await FirebaseFirestore.instance
            .collectionGroup('menuItems')
            .limit(500)
            .get();

        final filteredDocs = allItems.docs.where((doc) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().toLowerCase();
          final category = (data['category'] ?? '').toString().toLowerCase();
          final description = (data['description'] ?? '')
              .toString()
              .toLowerCase();

          return name.contains(formattedQuery) ||
              category.contains(formattedQuery) ||
              description.contains(formattedQuery);
        }).toList();

        searchResults.value = filteredDocs;
        if (filteredDocs.isEmpty) {
          await fetchRecommendations();
        }
      } else {
        // --- RESTAURANT SEARCH ---
        final allRestaurants = await FirebaseFirestore.instance
            .collection('restaurants')
            .limit(100)
            .get();

        final filteredDocs = allRestaurants.docs.where((doc) {
          final data = doc.data();
          final name = (data['restaurantName'] ?? '').toString().toLowerCase();
          final cuisine = (data['cuisineType'] ?? '').toString().toLowerCase();

          return name.contains(formattedQuery) ||
              cuisine.contains(formattedQuery);
        }).toList();

        searchResults.value = filteredDocs;
        if (filteredDocs.isEmpty) {
          await fetchRecommendations();
        }
      }
    } catch (e) {
      print("Search Error: $e");
      searchResults.clear();
      Get.snackbar(
        "Search Error",
        "Could not search: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecommendations() async {
    try {
      if (searchType.value == 'food') {
        // Fetch generic popular items (rating >= 4.5)
        final recQuery = await FirebaseFirestore.instance
            .collectionGroup('menuItems')
            .limit(20)
            .get();

        // sort by rating desc
        final docs = recQuery.docs;
        docs.sort((a, b) {
          final rA = (a.data()['rating'] ?? 0).toDouble();
          final rB = (b.data()['rating'] ?? 0).toDouble();
          return rB.compareTo(rA);
        });

        recommendedResults.value = docs.take(10).toList();
      } else {
        // Restaurant recommendations
        final recQuery = await FirebaseFirestore.instance
            .collection('restaurants')
            .limit(20)
            .get();

        final docs = recQuery.docs;
        // Simple client side sort/filter if needed, for now just take 10
        recommendedResults.value = docs.take(10).toList();
      }
    } catch (e) {
      print("Recommendation Error: $e");
    }
  }

  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    recommendedResults.clear();
    isSearching.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
