import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hungry/features/profile/profile_page.dart';
import 'package:hungry/features/profile/controllers/profile_controller.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Location & Profile
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFF5200), size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Home",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                    Obx(
                      () => Text(
                        controller.address.value.isNotEmpty
                            ? controller.address.value
                            : "Set your location",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Profile Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const ProfilePage());
                  },
                  child: const Icon(
                    Icons.person,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Greeting Text with Cool Font
          Obx(
            () => RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Hi ${controller.name.value.split(' ').first}, \n",
                    style: GoogleFonts.bebasNeue(
                      fontSize: 30,
                      color: Colors.black87,
                      height: 1.2,
                      letterSpacing: 1.0,
                    ),
                  ),
                  TextSpan(
                    text: "Are you craving?",
                    style: GoogleFonts.bebasNeue(
                      fontSize: 30,
                      color: const Color(0xFFFF5200), // Brand Color
                      height: 1.2,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
