import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/auth/presentation/pages/login.dart'; // Import Login Page

class ProfileController extends GetxController {
  var isLoading = true.obs;

  // User Data Observables
  var name = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var address = "".obs;
  var landmark = "".obs;
  var profileImage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Only set loading if name is empty (first load) to avoid flickering on re-fetches
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
          profileImage.value = data['profileImage'] ?? "";
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching user data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to Login Page and remove all previous routes
      Get.offAll(() => const DeliveryLoginPage());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to log out. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
