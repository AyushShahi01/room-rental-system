import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = AuthService();
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  String get email => emailController.text.trim();

  Future<void> sendOtp() async {
    if (isLoading.value) return;
    if (!GetUtils.isEmail(email)) {
      _showError('Invalid email', 'Enter a valid email address.');
      return;
    }
    try {
      isLoading.value = true;
      await _authService.requestPasswordReset(email);
      Get.toNamed(AppRoutes.verifyOtp);
    } on DioException catch (error) {
      _showError('Unable to send code', _messageFrom(error));
    } finally {
      isLoading.value = false;
    }
  }

  void verifyOtp() {
    final code = otpController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showError('Invalid code', 'Enter the 6-digit OTP sent to your email.');
      return;
    }
    otpController.text = code;
    // This API verifies the OTP atomically while changing the password. Calling
    // the general OTP endpoint here would mark this code as used too early.
    Get.toNamed(AppRoutes.resetPassword);
  }

  Future<void> resetPassword() async {
    if (isLoading.value) return;
    final password = newPasswordController.text;
    if (password.length < 8) {
      _showError('Weak password', 'Password must be at least 8 characters.');
      return;
    }
    if (password != confirmPasswordController.text) {
      _showError('Passwords do not match', 'Enter the same password twice.');
      return;
    }
    try {
      isLoading.value = true;
      await _authService.resetPassword(
        email: email,
        otpCode: otpController.text,
        newPassword: password,
      );
      Get.offAllNamed(AppRoutes.passwordResetSuccess);
    } on DioException catch (error) {
      _showError('Password reset failed', _messageFrom(error));
    } finally {
      isLoading.value = false;
    }
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['error'] ?? data['detail'] ?? data['message'];
      if (message != null) return message.toString();
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Check your internet connection and try again.';
    }
    return 'Please try again shortly.';
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
