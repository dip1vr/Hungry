import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:hungry/features/home/presentation/pages/home_page.dart';
import 'package:hungry/features/auth/presentation/widgets/auth_widgets.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showStyledSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 14),
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

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        await credential.user?.updateDisplayName(nameController.text.trim());

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
              'name': nameController.text.trim(),
              'email': emailController.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
              'signup_date':
                  FieldValue.serverTimestamp(), // Added explicit signup date
              'last_activity_time': FieldValue.serverTimestamp(),
              'isBlocked': false, // Default to not blocked
            });

        _showStyledSnackBar(context, 'Account created successfully!');

        Get.offAll(() => const HomePage());
      } on FirebaseAuthException catch (e) {
        String message = 'Signup failed';
        if (e.code == 'email-already-in-use') {
          message = 'Email already in use';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email address';
        } else if (e.code == 'weak-password') {
          message = 'Password is too weak';
        }
        _showStyledSnackBar(context, message, isError: true);
      } catch (e) {
        _showStyledSnackBar(
          context,
          'Something went wrong. Try again.',
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
                          "Create Account",
                          style: TextStyle(
                            fontSize: 38,
                            color: Colors.black87,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "Join the food revolution!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Name Field
                        TextFormField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: _buildInputDecoration(
                            "Full Name",
                            FeatherIcons.user,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        TextFormField(
                          controller: emailController,
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
                        TextFormField(
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: Colors.black87),
                          decoration:
                              _buildInputDecoration(
                                "Password",
                                FeatherIcons.lock,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () => setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  ),
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Min 6 characters required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: const TextStyle(color: Colors.black87),
                          decoration:
                              _buildInputDecoration(
                                "Confirm Password",
                                FeatherIcons.checkCircle,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () => setState(
                                    () => _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible,
                                  ),
                                ),
                              ),
                          validator: (value) {
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Signup Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignup,
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
                                    "SIGN UP",
                                    style: TextStyle(
                                      fontSize: 20,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Sign in",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: const Color(0xFFFF5200),
                                  fontWeight: FontWeight.bold,
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
