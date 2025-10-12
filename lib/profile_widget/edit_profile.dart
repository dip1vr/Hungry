import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFFF8C00);
const kAccentColor = Color(0xFFE91E63);
const kBackgroundColor = Color(0xFFF5F7FA);

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Profile fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _deliveryInstructionsController =
      TextEditingController();

  File? _profileImage;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Load data when page opens
  }

  Future<void> _fetchUserData() async {
  setState(() => _isLoading = true);

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // ✅ Force reload so latest email & displayName are available
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(refreshedUser!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
       
        _phoneController.text = data['phone'] ?? '';
         _nameController.text =data['name'] ?? '';
        _altPhoneController.text = data['altPhone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _cityController.text = data['city'] ?? '';
        _stateController.text = data['state'] ?? '';
        _zipController.text = data['zip'] ?? '';
        _landmarkController.text = data['landmark'] ?? '';
        _deliveryInstructionsController.text = data['deliveryInstructions'] ?? '';
      }
    }
  } catch (e) {
    debugPrint("Error fetching user data: $e");
  } finally {
    setState(() => _isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/Midjourney.jpg", fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
            child: Column(
              children: [
                // Profile Picture (image picker commented)
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!) as ImageProvider
                            : const NetworkImage(
                                "https://i.pravatar.cc/150?img=5",
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: "Full Name",
                          icon: Icons.person,
                        ),
                     
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _altPhoneController,
                          label: "Alternate Phone (Optional)",
                          icon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 25),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Address Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _addressController,
                          label: "Street / Address",
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _cityController,
                          label: "City",
                          icon: Icons.location_city,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _stateController,
                          label: "State / Region",
                          icon: Icons.map,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _zipController,
                          label: "ZIP / Postal Code",
                          icon: Icons.markunread_mailbox,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _landmarkController,
                          label: "Landmark (Optional)",
                          icon: Icons.flag,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _deliveryInstructionsController,
                          label: "Delivery Instructions (Optional)",
                          icon: Icons.note,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 35),

                // Save Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : GestureDetector(
                        onTap: () => _saveProfile(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kPrimaryColor, kAccentColor],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: kAccentColor.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: kPrimaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Save Changes",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: (value) {
        if (value!.isEmpty && !label.toLowerCase().contains("optional"))
          return "Please enter $label";
        if (!readOnly &&
            label == "Email" &&
            !RegExp(r'\S+@\S+\.\S+').hasMatch(value))
          return "Enter a valid email";
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kPrimaryColor),
        filled: true,
        fillColor: kBackgroundColor,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: kPrimaryColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update displayName only (email fixed)

        // Save additional data in Firestore
        final data = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'altPhone': _altPhoneController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zip': _zipController.text.trim(),
          'landmark': _landmarkController.text.trim(),
          'deliveryInstructions': _deliveryInstructionsController.text.trim(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(data, SetOptions(merge: true));

        // Print everything
        print("✅ User UID: ${user.uid}");
        print("Updated profile data: $data");
        print("Profile updated successfully!");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
