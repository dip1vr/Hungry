import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hungry/app.dart';
import 'package:hungry/core/services/notification_service.dart';
// import 'package:hungry/features/home/presentation/pages/home_page.dart'; // No longer needed here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDVLjv3V3LU6h_MbAgjyDiY_Y1yt5Ov-wk",
        appId: "1:1066214452856:android:3ba59a52565d5cefd6478d",
        messagingSenderId: "1066214452856",
        projectId: "deliveryapp-b595e",
        storageBucket: "deliveryapp-b595e.firebasestorage.app",
        databaseURL: "https://deliveryapp-b595e-default-rtdb.firebaseio.com",
      ),
    );
    debugPrint("✅ Firebase Initialized Successfully!");

    // Initialize Notification Service
    await NotificationService().init();
  } catch (e) {
    debugPrint("❌ Firebase Initialization Failed: $e");
  }

  runApp(const ProviderScope(child: HungryApp()));
}
