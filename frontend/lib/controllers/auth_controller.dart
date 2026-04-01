import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // User Data
  final RxString userName = 'Guest'.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userAddress = ''.obs;

  // Role (Default Tenant)
  final RxString selectedRole = 'Tenant'.obs;

  // Password Visibility
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

  // ================= LOGIN =================
  void login() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter email and password');
      return;
    }

    // Save user data
    userEmail.value = emailController.text.trim();
    userName.value = emailController.text.split('@').first;

    // IMPORTANT: Do NOT change role here
    // Role comes from UI selection

    navToHome();
  }

  // ================= REGISTER =================
  void register() {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    // Save user data
    userName.value = nameController.text.trim();
    userEmail.value = emailController.text.trim();
    userPhone.value = phoneController.text.trim();
    userAddress.value = addressController.text.trim();

    // Navigate based on selected role
    navToHome();
  }

  // ================= NAVIGATION =================
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

  // ================= PASSWORD VISIBILITY =================
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

  // ================= OTP =================
  void sendOtp() {
    if (emailController.text.trim().isEmpty &&
        phoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Enter email or phone number');
      return;
    }

    Get.offNamed(AppRoutes.verifyOtp);
  }

  void verifyOtp() {
    if (otpController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter OTP');
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
