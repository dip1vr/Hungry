import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hungry/auth/signup.dart';
import 'package:hungry/auth/auth_widgets.dart'; // Import the new widgets
import 'package:hungry/features/dashboard/dashboard_page.dart';

class DeliveryLoginPage extends StatefulWidget {
  const DeliveryLoginPage({super.key});

  @override
  _DeliveryLoginPageState createState() => _DeliveryLoginPageState();
}

class _DeliveryLoginPageState extends State<DeliveryLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showStyledSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.lato(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: isError
            ? Colors.redAccent.withOpacity(0.9)
            : Colors.green.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

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

        if (mounted) {
          _showStyledSnackBar(context, "Welcome back, $welcomeName!");
          Get.offAll(() => const DashboardPage());
        }
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
        if (mounted) _showStyledSnackBar(context, message, isError: true);
      } catch (e) {
        if (mounted)
          _showStyledSnackBar(
            context,
            "An unexpected error occurred",
            isError: true,
          );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          "Welcome Back",
                          style: GoogleFonts.bebasNeue(
                            fontSize: 42,
                            color: Colors.black87,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "Let's get you fed!",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Email Field
                        TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: _buildInputDecoration(
                            "Email Address",
                            FeatherIcons.mail,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty)
                              return 'Email is required';
                            if (!GetUtils.isEmail(value.trim()))
                              return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscureText,
                          style: const TextStyle(color: Colors.black87),
                          decoration:
                              _buildInputDecoration(
                                "Password",
                                FeatherIcons.lock,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureText = !_obscureText,
                                  ),
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty)
                              return 'Password is required';
                            return null;
                          },
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
                                  child: Checkbox(
                                    value: rememberMe,
                                    onChanged: (v) =>
                                        setState(() => rememberMe = v!),
                                    activeColor: const Color(0xFFFF5200),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Remember me",
                                  style: GoogleFonts.lato(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                if (emailController.text.trim().isEmpty) {
                                  _showStyledSnackBar(
                                    context,
                                    "Enter email first",
                                  );
                                } else {
                                  FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                        email: emailController.text.trim(),
                                      )
                                      .then(
                                        (_) => _showStyledSnackBar(
                                          context,
                                          "Reset link sent!",
                                        ),
                                      );
                                }
                              },
                              child: Text(
                                "Forgot?",
                                style: GoogleFonts.lato(
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
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _loginUser,
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
                            child: _isLoading
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
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 20,
                                      letterSpacing: 1.2,
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
                              style: GoogleFonts.lato(
                                color: Colors.grey[600],
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.to(() => const Signup()),
                              child: Text(
                                "Join Now",
                                style: GoogleFonts.lato(
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
