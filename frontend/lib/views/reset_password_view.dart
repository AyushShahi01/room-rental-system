import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.lock_outline, size: 64, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                'Create a new password',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Obx(
                () => TextField(
                  controller: controller.newPasswordController,
                  autofillHints: const [AutofillHints.newPassword],
                  obscureText: !controller.isNewPasswordVisible.value,
                  decoration: _passwordDecoration(
                    label: 'New password',
                    visible: controller.isNewPasswordVisible.value,
                    onPressed: controller.isNewPasswordVisible.toggle,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => TextField(
                  controller: controller.confirmPasswordController,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => controller.resetPassword(),
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  decoration: _passwordDecoration(
                    label: 'Confirm new password',
                    visible: controller.isConfirmPasswordVisible.value,
                    onPressed: controller.isConfirmPasswordVisible.toggle,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Reset Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _passwordDecoration({
    required String label,
    required bool visible,
    required VoidCallback onPressed,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock_outline),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      suffixIcon: IconButton(
        icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
        onPressed: onPressed,
      ),
    );
  }
}
