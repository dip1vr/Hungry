import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  late final PageController pageController = PageController(initialPage: 0);

  void changeIndex(int index) {
    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Observable lists for data
  final RxList<DocumentSnapshot> featuredRestaurants = <DocumentSnapshot>[].obs;
  final RxList<DocumentSnapshot> recommendedItems = <DocumentSnapshot>[].obs;

  // Scroll Controller for pagination
  final ScrollController scrollController = ScrollController();

  // Pagination Variables
  final int _limit = 10;
  DocumentSnapshot? _lastDocument;
  var isMoreLoading = false.obs;
  var hasMore = true.obs;
  var isLoadingFirstBatch = true.obs;

  // Search Variables
  var searchQuery = ''.obs;
  var isSearching = false.obs;
  var isSearchLoading = false.obs;
  RxList<DocumentSnapshot> searchResultsRestaurants = <DocumentSnapshot>[].obs;
  RxList<DocumentSnapshot> searchResultsFood = <DocumentSnapshot>[].obs;
  Timer? _debounce;

  void stopSearch() {
    isSearching.value = false;
    searchQuery.value = '';
    searchResultsRestaurants.clear();
    searchResultsFood.clear();
  }

  void search(String query) {
    searchQuery.value = query;
    isSearching.value = true;
    isSearchLoading.value = true;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        String effectiveQuery = query.trim();

        Query<Map<String, dynamic>> restaurantRef = FirebaseFirestore.instance
            .collection('restaurants');
        Query<Map<String, dynamic>> foodRef = FirebaseFirestore.instance
            .collectionGroup('menuItems');

        if (effectiveQuery.isEmpty) {
          final rRes = await restaurantRef.limit(10).get();
          final fRes = await foodRef.limit(20).get();

          searchResultsRestaurants.value = rRes.docs;
          searchResultsFood.value = fRes.docs;
        } else {
          // 1. Client-side Search (Smart Match) on already loaded Featured Restaurants
          final localMatches = featuredRestaurants.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['restaurantName'] ?? '')
                .toString()
                .toLowerCase();
            return name.contains(effectiveQuery.toLowerCase());
          }).toList();

          // 2. Firestore Search (Title Case Prefix Match)
          String firestoreQuery = effectiveQuery;
          if (firestoreQuery.length > 1) {
            firestoreQuery =
                firestoreQuery[0].toUpperCase() +
                firestoreQuery.substring(1).toLowerCase();
          } else {
            firestoreQuery = firestoreQuery.toUpperCase();
          }

          final restaurantQuery = await restaurantRef
              .where('restaurantName', isGreaterThanOrEqualTo: firestoreQuery)
              .where(
                'restaurantName',
                isLessThanOrEqualTo: firestoreQuery + '\uf8ff',
              )
              .get();

          final foodQuery = await foodRef
              .where('name', isGreaterThanOrEqualTo: firestoreQuery)
              .where('name', isLessThanOrEqualTo: firestoreQuery + '\uf8ff')
              .limit(20)
              .get();

          // Merge Local + Firestore results (deduplicating by ID)
          final allRestaurants = <String, DocumentSnapshot>{};
          for (var doc in localMatches) {
            allRestaurants[doc.id] = doc;
          }
          for (var doc in restaurantQuery.docs) {
            allRestaurants[doc.id] = doc;
          }

          searchResultsRestaurants.value = allRestaurants.values.toList();
          searchResultsFood.value = foodQuery.docs;
        }
      } catch (e) {
        print("Search Error: $e");
      } finally {
        isSearchLoading.value = false;
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
    _fetchInitialRecommendedData();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        _loadMoreRecommendedData();
      }
    });
  }

  void _bindStreams() {
    featuredRestaurants.bindStream(
      FirebaseFirestore.instance
          .collection('restaurants')
          .snapshots()
          .map((query) => query.docs),
    );
  }

  Future<void> _fetchInitialRecommendedData() async {
    try {
      isLoadingFirstBatch.value = true;
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('menuItems')
          .limit(_limit)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        recommendedItems.value = querySnapshot.docs;
        hasMore.value = querySnapshot.docs.length == _limit;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      print("Error fetching initial recommended data: $e");
    } finally {
      isLoadingFirstBatch.value = false;
    }
  }

  Future<void> _loadMoreRecommendedData() async {
    if (isMoreLoading.value || !hasMore.value || _lastDocument == null) return;

    try {
      isMoreLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));

      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('menuItems')
          .startAfterDocument(_lastDocument!)
          .limit(_limit)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        recommendedItems.addAll(querySnapshot.docs);
        hasMore.value = querySnapshot.docs.length == _limit;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      print("Error loading more recommended data: $e");
    } finally {
      isMoreLoading.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
