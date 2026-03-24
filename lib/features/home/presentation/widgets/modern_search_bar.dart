import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/search/search_page.dart';

class ModernSearchBar extends StatelessWidget {
  const ModernSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Get.to(
            () => const SearchPage(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 300),
          );
        },
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ), // Replaces withOpacity(0.04)
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(
                  0xFFFF725E,
                ).withValues(alpha: 0.05), // Subtle brand hint
                blurRadius: 8,
                offset: const Offset(0, 2),
              ), // Brand hint
            ],
            border: Border.all(
              color: Colors.grey.withValues(
                alpha: 0.1,
              ), // Replaces withOpacity(0.1)
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(
                Icons.search_rounded,
                color: Color(0xFFFF725E), // Brand Color
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "What are you craving?",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
