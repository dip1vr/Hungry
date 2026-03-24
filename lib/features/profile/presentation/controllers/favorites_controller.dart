import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FavoritesController extends GetxController {
  var favorites = <String>[].obs; // List of restaurant IDs
  var favoriteItems = <Map<String, dynamic>>[]
      .obs; // List of full restaurant data for the Favorites page
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    print("FavoritesController initialized");
    // Listen to user auth state to start/stop listening to favorites
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print("User logged in: ${user.uid}");
        _listenToFavorites(user.uid);
      } else {
        print("User logged out");
        favorites.clear();
        favoriteItems.clear();
      }
    });
  }

  void _listenToFavorites(String uid) {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .listen(
          (snapshot) {
            print("Favorites update received: ${snapshot.docs.length} items");
            favorites.value = snapshot.docs.map((doc) => doc.id).toList();
            favoriteItems.value = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id; // Ensure ID is part of the data
              return data;
            }).toList();
          },
          onError: (e) {
            print("Error listening to favorites: $e");
          },
        );
  }

  Future<void> toggleFavorite(
    String restaurantId,
    Map<String, dynamic> restaurantData,
  ) async {
    print("Toggling favorite for $restaurantId");
    final user = _auth.currentUser;
    if (user == null) {
      print("User is null, cannot toggle favorite");
      Get.snackbar("Error", "You must be logged in to add favorites");
      return;
    }

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(restaurantId);

    try {
      if (favorites.contains(restaurantId)) {
        print("Removing from favorites");
        // Remove
        await docRef.delete();
        // Optional: Show snackbar
        // Get.snackbar("Removed", "Removed from favorites", snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
      } else {
        print("Adding to favorites");
        // Add
        await docRef.set(restaurantData);
        Get.snackbar(
          "Added to Favorites",
          "${restaurantData['name']} is now in your favorites!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }
    } catch (e) {
      print("Error toggling favorite: $e");
      Get.snackbar("Error", "Could not action: $e");
    }
  }

  bool isFavorite(String restaurantId) {
    return favorites.contains(restaurantId);
  }
}
