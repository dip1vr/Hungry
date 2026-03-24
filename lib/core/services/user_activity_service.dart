import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Import Material
import 'package:get/get.dart';

class UserActivityService extends GetxService {
  static UserActivityService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _monitorUserStatus();
  }

  /// Monitors the user's status (e.g., Blocked) in real-time.
  void _monitorUserStatus() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore.collection('users').doc(user.uid).snapshots().listen((
      snapshot,
    ) async {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (data['isBlocked'] == true) {
          // User is blocked - Log out immediately
          await _auth.signOut();
          Get.offAllNamed('/'); // Or navigate to a specific Blocked Screen

          Get.dialog(
            WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: const Text("Account Blocked"),
                content: const Text(
                  "Your account has been blocked by the administrator. Please contact support.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.offAllNamed('/'); // Close dialog and ensure on login
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            ),
            barrierDismissible: false,
          );
        }
      }
    });
  }

  /// Updates the 'last_activity_time' field for the current user.
  Future<void> updateLastActivity() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'last_activity_time': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // If the document doesn't exist, we might want to set it instead of update,
      // or just ignore if the user doc isn't created yet.
      // silent failure is acceptable here to not block user flow
      print("Error updating last activity: $e");
    }
  }

  /// Logs a specific activity to a subcollection and updates last_activity_time
  Future<void> logActivity(String type, {String? details}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Update the main user document active status
      await updateLastActivity();

      // 2. Log the specific event to a subcollection 'activity_logs'
      // This is useful for detailed analytics 'order history', 'clicks', etc.
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('activity_logs')
          .add({
            'type': type,
            'details': details,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print("Error logging activity: $e");
    }
  }
}
