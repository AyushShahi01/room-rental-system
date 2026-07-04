import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    // Make sure we clear password fields when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.clearPasswordForm();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final isLoading = authController.isLoading.value;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Security Shield Illustration Icon ─────────────────────
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security_outlined,
                        size: 48,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Create a Strong Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your new password must be at least 8 characters long and differ from your old password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Old Password Field ────────────────────────────────────
                  Obx(() => _passwordTextField(
                        controller: authController.oldPasswordController,
                        labelText: 'Current Password',
                        hintText: 'Enter current password',
                        isVisible: authController.isOldPasswordVisible.value,
                        onToggleVisibility: authController.toggleOldPasswordVisibility,
                      )),
                  const SizedBox(height: 16),

                  // ─── New Password Field ────────────────────────────────────
                  Obx(() => _passwordTextField(
                        controller: authController.newPasswordController,
                        labelText: 'New Password',
                        hintText: 'Enter new password (min 8 chars)',
                        isVisible: authController.isNewPasswordVisible.value,
                        onToggleVisibility: authController.toggleNewPasswordVisibility,
                      )),
                  const SizedBox(height: 16),

                  // ─── Confirm New Password Field ────────────────────────────
                  Obx(() => _passwordTextField(
                        controller: authController.confirmPasswordController,
                        labelText: 'Confirm New Password',
                        hintText: 'Re-enter new password',
                        isVisible: authController.isConfirmPasswordVisible.value,
                        onToggleVisibility: authController.toggleConfirmPasswordVisibility,
                      )),
                  const SizedBox(height: 32),

                  // ─── Save Button ───────────────────────────────────────────
                  ElevatedButton(
                    onPressed: isLoading ? null : authController.changePassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.blueAccent.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Update Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.15),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _passwordTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
    );
  }
}
