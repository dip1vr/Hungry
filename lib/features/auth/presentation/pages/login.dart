import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';


import 'package:hungry/features/auth/presentation/pages/signup.dart';
import 'package:hungry/features/auth/presentation/widgets/auth_widgets.dart';
import 'package:hungry/features/auth/presentation/controllers/login_controller.dart';

class DeliveryLoginPage extends StatelessWidget {
  const DeliveryLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: ModernAuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FadeInUp(
                delay: 200,
                child: AuthCard(
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 42,
                            color: Colors.black87,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "Let's get you fed!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Email Field
                        TextFormField(
                          controller: controller.emailController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: _buildInputDecoration(
                            "Email Address",
                            FeatherIcons.mail,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!GetUtils.isEmail(value.trim())) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Obx(
                          () => TextFormField(
                            controller: controller.passwordController,
                            obscureText: controller.obscureText.value,
                            style: const TextStyle(color: Colors.black87),
                            decoration:
                                _buildInputDecoration(
                                  "Password",
                                  FeatherIcons.lock,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscureText.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed:
                                        controller.togglePasswordVisibility,
                                  ),
                                ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Remember Me & Forgot PW
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Obx(
                                    () => Checkbox(
                                      value: controller.rememberMe.value,
                                      onChanged: controller.toggleRememberMe,
                                      activeColor: const Color(0xFFFF5200),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Remember me",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: controller.resetPassword,
                              child: Text(
                                "Forgot?",
                                style: TextStyle(
                                  color: const Color(0xFFFF5200),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.loginUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5200),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: const Color(
                                  0xFFFF5200,
                                ).withOpacity(0.4),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      "SIGN IN",
                                      style: TextStyle(
                                        fontSize: 20,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Signup Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New to Hungry? ",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.to(() => const Signup()),
                              child: Text(
                                "Join Now",
                                style: TextStyle(
                                  color: const Color(0xFFFF5200),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      filled: true,
      fillColor: Colors.grey[50], // Very light grey fill
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF5200), width: 1.2),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}
