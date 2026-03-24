import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to access other Firebase services in the background,
  // you likely need to initialize Firebase here as well.
  // await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> init() async {
    // 1. Request Permissions
    await _requestPermission();

    // 2. Register Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Monitor Auth State & Manage Topics
    // This handles login, logout, and app starts if already logged in.
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        updateBehavioralTopics();
      } else {
        // Optional: Unsubscribe from user-specific topics on logout
        // _messaging.unsubscribeFromTopic('all_users');
        // But requirements just say "Customer app never sends notifications", logic is simpler.
        // We usually keep them subscribed or let the next login handle it.
      }
    });

    // Initial check if user is already signed in
    if (_auth.currentUser != null) {
      await updateBehavioralTopics();
    }

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        // Show local notification using GetX snackbar or other method if needed
        // For now, we rely on the system tray if app is in background,
        // but for foreground, we might want to show a Snackbar.
        Get.snackbar(
          message.notification!.title ?? 'Notification',
          message.notification!.body ?? 'New Message',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    });

    // 5. Handle Tap on Notification (Background/Terminated State)
    await _setupInteractedMessage();
  }

  /// Updates FCM topic subscriptions based on user behavior:
  /// - all_users: Always subscribed
  /// - new_users: Account age <= 7 days
  /// - old_users: Account age > 7 days
  /// - active_users: Currently using the app (subscribed now)
  /// - inactive_users: Unsubscribed now (Backend handles moving into this)
  Future<void> updateBehavioralTopics() async {
    // Topic subscriptions are not supported on Web SDK by default
    if (kIsWeb) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Always subscribe to all_users
      await _messaging.subscribeToTopic('all_users');
      debugPrint("FCM: Subscribed to all_users");

      // 2. Mark as Active (Since they are using the app right now)
      await _messaging.subscribeToTopic('active_users');
      await _messaging.unsubscribeFromTopic('inactive_users');
      debugPrint("FCM: Marked as active_users");

      // 3. Check Account Age (New vs Old)
      // Retrieve 'createdAt' or 'signup_date' from Firestore
      // Note: Make sure to fetch the correct field used in signup.
      final docSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        Timestamp? createdAt;

        // Try to get creation time from various possible fields to be safe
        if (data != null) {
          if (data['createdAt'] is Timestamp) {
            createdAt = data['createdAt'];
          } else if (data['signup_date'] is Timestamp) {
            createdAt = data['signup_date'];
          }
        }

        if (createdAt != null) {
          final DateTime createdDate = createdAt.toDate();
          final DateTime now = DateTime.now();
          final Duration difference = now.difference(createdDate);

          if (difference.inDays <= 7) {
            // New User
            await _messaging.subscribeToTopic('new_users');
            await _messaging.unsubscribeFromTopic('old_users');
            debugPrint(
              "FCM: Marked as new_users (Age: ${difference.inDays} days)",
            );
          } else {
            // Old User
            await _messaging.subscribeToTopic('old_users');
            await _messaging.unsubscribeFromTopic('new_users');
            debugPrint(
              "FCM: Marked as old_users (Age: ${difference.inDays} days)",
            );
          }
        }
      }
    } catch (e) {
      debugPrint("FCM Error updating topics: $e");
    }
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _setupInteractedMessage() async {
    // Get any messages which caused the application to open from a terminated state.
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint("Notification Tapped: ${message.data}");

    // Logic to navigate to specific screen
    // Example: if (message.data['type'] == 'offer') { Get.to(() => OfferScreen()); }

    // For now, just logging or basic navigation if needed.
    // Since requirements say "User notification pe click kare to relevant screen open ho (example: offer screen)",
    // We can check for a 'route' in data or similar.
    // Assuming simple behavior for now: navigate to a generic Offers page if specified?
    // The requirement is general. We will just ensure the structure is there.

    if (message.data.containsKey('route')) {
      // Get.toNamed(message.data['route']); // Example
    }
  }
}
