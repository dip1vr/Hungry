import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;

  // User Data Observables
  var name = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var address = "".obs;
  var landmark = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // If we already have data (e.g. name is not empty), maybe we don't need to show loading,
    // but for freshness we usually fetch. The user asked for "load once",
    // but if we call this in onInit, it only runs once when controller is created (app start).
    // So this IS the "load once" behavior.

    // Only set loading if name is empty (first load) to avoid flickering on re-fetches (if invoked manually)
    if (name.value.isEmpty) isLoading.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;
        email.value = refreshedUser?.email ?? "";

        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(refreshedUser!.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          name.value = data['name'] ?? "";
          phone.value = data['phone'] ?? "";
          address.value = data['address'] ?? "";
          landmark.value = data['landmark'] ?? "";
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching user data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
