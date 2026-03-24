import 'package:flutter/material.dart';
import 'package:get/get.dart';
//  // No longer needed
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hungry/core/services/user_activity_service.dart';
import 'package:hungry/features/home/presentation/pages/home_page.dart';
import 'package:hungry/features/auth/presentation/pages/login.dart';
import 'package:hungry/core/theme/app_theme.dart';

class HungryApp extends StatelessWidget {
  const HungryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize UserActivityService
    Get.put(UserActivityService());

    // Log App Open
    Future.delayed(Duration.zero, () {
      if (FirebaseAuth.instance.currentUser != null) {
        UserActivityService.to.logActivity('app_open');
      }
    });

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FirebaseAuth.instance.currentUser != null
          ? const HomePage()
          : const DeliveryLoginPage(),
    );
  }
}
