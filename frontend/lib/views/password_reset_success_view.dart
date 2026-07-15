import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class PasswordResetSuccessView extends StatelessWidget {
  const PasswordResetSuccessView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, size: 80, color: Colors.blueAccent),
        const SizedBox(height: 20),
        const Text('Password reset successful', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('You can now log in using your new password.', textAlign: TextAlign.center),
        const SizedBox(height: 28),
        ElevatedButton(onPressed: () => Get.offAllNamed(AppRoutes.login), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white), child: const Text('Back to Login')),
      ]),
    )),
  );
}
