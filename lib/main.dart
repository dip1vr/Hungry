import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hungry/auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDVLjv3V3LU6h_MbAgjyDiY_Y1yt5Ov-wk",
        appId: "1:1066214452856:android:3ba59a52565d5cefd6478d", // ✅ updated
        messagingSenderId: "1066214452856",
        projectId: "deliveryapp-b595e",
        storageBucket: "deliveryapp-b595e.firebasestorage.app",
        databaseURL:
            "https://deliveryapp-b595e-default-rtdb.firebaseio.com", // ✅ added
      ),
    );
    print("✅ Firebase Initialized Successfully!");
  } catch (e) {
    print("❌ Firebase Initialization Failed: $e");
  }

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ProviderScope(child: const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.latoTextTheme()),
      home: Scaffold(body: DeliveryLoginPage()),
    );
  }
}
