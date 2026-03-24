import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hungry/features/home/presentation/pages/home_page.dart';
import 'package:hungry/core/services/user_activity_service.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var rememberMe = false.obs;
  var obscureText = true.obs;
  var isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleRememberMe(bool? value) {
    if (value != null) {
      rememberMe.value = value;
    }
  }

  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  Future<void> loginUser() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        String welcomeName = credential.user?.displayName ?? 'User';
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            if (data['name'] != null && data['name'].toString().isNotEmpty) {
              welcomeName = data['name'];
            }
          }
        } catch (_) {}

        Get.snackbar(
          "Success",
          "Welcome back, $welcomeName!",
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
        );

        UserActivityService.to.logActivity('login');
        Get.offAll(() => const HomePage());
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'user-not-found':
          case 'invalid-email':
            message = 'No user found with this email.';
            break;
          case 'wrong-password':
          case 'invalid-credential':
            message = 'Incorrect password or email.';
            break;
          case 'user-disabled':
            message = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            message = 'Too many failed attempts. Try again later.';
            break;
          case 'network-request-failed':
            message = 'Network error. Check your connection.';
            break;
          default:
            message = e.message ?? 'Login failed. Please try again.';
        }
        Get.snackbar(
          "Login Failed",
          message,
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "An unexpected error occurred",
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(20),
          borderRadius: 12,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  void resetPassword() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        "Required",
        "Enter email first",
        backgroundColor: Colors.orangeAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
    } else {
      FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim())
          .then((_) {
            Get.snackbar(
              "Sent",
              "Reset link sent!",
              backgroundColor: Colors.green.withOpacity(0.9),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(20),
              borderRadius: 12,
            );
          });
    }
  }
}
