import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxString userName = 'Guest'.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userAddress = ''.obs;

  final RxString selectedRole = 'Tenant'.obs;

  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isRegisterPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password');
      return;
    }

    if (!email.endsWith('@gmail.com')) {
      Get.snackbar('Error', 'Email must be a valid Gmail address');
      return;
    }

    if (password.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters');
      return;
    }

    userEmail.value = email;
    userName.value = email.split('@').first;

    navToHome();
  }

  void register() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (nameController.text.trim().isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    if (!email.endsWith('@gmail.com')) {
      Get.snackbar('Error', 'Email must be a valid Gmail address');
      return;
    }

    if (password.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters');
      return;
    }

    userName.value = nameController.text.trim();
    userEmail.value = email;
    userPhone.value = phoneController.text.trim();
    userAddress.value = addressController.text.trim();

    navToHome();
  }

  void navToHome() {
    if (selectedRole.value == 'Landlord') {
      Get.offNamed(AppRoutes.landlordDashboard);
    } else {
      Get.offNamed(AppRoutes.home);
    }
  }

  void goToLogin() {
    Get.offNamed(AppRoutes.login);
  }

  void goToRegister() {
    Get.offNamed(AppRoutes.register);
  }

  void goToForgotPassword() {
    Get.offNamed(AppRoutes.forgotPassword);
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible.value = !isRegisterPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void sendOtp() {
    if (emailController.text.trim().isEmpty &&
        phoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Enter email or phone number');
      return;
    }

    Get.offNamed(AppRoutes.verifyOtp);
  }

  void verifyOtp() {
    if (otpController.text.trim().length != 6) {
      Get.snackbar('Error', 'Please enter a 6-digit OTP');
      return;
    }

    Get.offNamed(AppRoutes.resetPassword);
  }

  void resetPassword() {
    if (newPasswordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Fields cannot be empty');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    Get.snackbar('Success', 'Password changed successfully');
    Get.offNamed(AppRoutes.login);
  }
}
