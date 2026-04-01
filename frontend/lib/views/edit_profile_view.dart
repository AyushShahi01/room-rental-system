import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get existing auth controller
    final AuthController authCtrl = Get.find<AuthController>();

    // Local controllers initialized with current values
    final nameCtrl = TextEditingController(text: authCtrl.userName.value);
    final emailCtrl = TextEditingController(text: authCtrl.userEmail.value);
    final phoneCtrl = TextEditingController(text: authCtrl.userPhone.value);
    final addressCtrl = TextEditingController(text: authCtrl.userAddress.value);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 50, color: Colors.blueAccent),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Name Field
            _buildTextField(
              label: 'Full Name',
              icon: Icons.person_outline,
              controller: nameCtrl,
            ),
            const SizedBox(height: 20),
            
            // Email Field
            _buildTextField(
              label: 'Email Address',
              icon: Icons.email_outlined,
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            
            // Phone Field
            _buildTextField(
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            
            // Address Field
            _buildTextField(
              label: 'Address',
              icon: Icons.location_on_outlined,
              controller: addressCtrl,
            ),
            
            const SizedBox(height: 48),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Save updated data directly into AuthController's reactive variables
                  authCtrl.userName.value = nameCtrl.text;
                  authCtrl.userEmail.value = emailCtrl.text;
                  authCtrl.userPhone.value = phoneCtrl.text;
                  authCtrl.userAddress.value = addressCtrl.text;
                  
                  Get.back(); // Go back to the previous screen
                  Get.snackbar(
                    'Success',
                    'Profile updated successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blueAccent.withOpacity(0.4),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }
}
