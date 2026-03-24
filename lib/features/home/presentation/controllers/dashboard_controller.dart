import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hungry/core/services/user_activity_service.dart'; // Import UserActivityService
import 'package:hungry/features/profile/presentation/controllers/profile_controller.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  late final PageController pageController = PageController(initialPage: 0);

  void changeIndex(int index) {
    // Check if the jump is adjacent (diff == 1)
    if ((selectedIndex.value - index).abs() > 1) {
      // Non-adjacent: Jump instantly to avoid "scanning" glitch
      pageController.jumpToPage(index);
    } else {
      // Adjacent: Smooth scroll animation
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    selectedIndex.value = index;
    // Log dashboard navigation
    if (Get.isRegistered<UserActivityService>()) {
      UserActivityService.to.logActivity(
        'dashboard_nav',
        details: 'tab_$index',
      );
    }
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

  // Loading State
  var isDashboardLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Log Dashboard View Activity
    if (Get.isRegistered<UserActivityService>()) {
      UserActivityService.to.logActivity('dashboard_view');
    }
    _bindStreams();
    _fetchInitialRecommendedData();

    // Simulate a minimum loading time for smooth UX
    // In a real app, this would depend on stream events, but since streams push data continuously,
    // we can wait for a reasonable initial delay or simply wait for the first batch of futures.
    Future.delayed(const Duration(seconds: 2), () {
      isDashboardLoading.value = false;
    });

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
        final List<DocumentSnapshot> shuffledDocs = List.from(
          querySnapshot.docs,
        )..shuffle();
        recommendedItems.value = shuffledDocs;
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
        // Randomize the items for variety
        final List<DocumentSnapshot> shuffledDocs = List.from(
          querySnapshot.docs,
        )..shuffle();
        recommendedItems.addAll(shuffledDocs);
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

  Future<void> refreshDashboard() async {
    // Show skeleton loading state
    isDashboardLoading.value = true;

    // Reset pagination state
    _lastDocument = null;
    hasMore.value = true;
    isMoreLoading.value = false;

    // Clear existing data to show loading indicators
    featuredRestaurants.clear();
    recommendedItems.clear();

    // Re-bind the stream to force a fresh connection/check
    _bindStreams();

    // Fetch the first batch of recommended items again
    final recommendedFuture = _fetchInitialRecommendedData();

    // Also refresh profile data (Location/Name) if available
    Future<void>? profileFuture;
    if (Get.isRegistered<ProfileController>()) {
      profileFuture = Get.find<ProfileController>().fetchUserData();
    }

    // Wait for all fetches and minimum 2 seconds delay
    await Future.wait([
      recommendedFuture,
      if (profileFuture != null) profileFuture,
      // Ensure minimum loading time of 2 seconds as requested
      Future.delayed(const Duration(seconds: 2)),
    ]);

    // Hide skeleton loading state
    isDashboardLoading.value = false;
  }

  @override
  void onClose() {
    pageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
