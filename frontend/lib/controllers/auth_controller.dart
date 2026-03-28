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
    if (emailController.text.isNotEmpty) {
      userEmail.value = emailController.text;

      // Auto-generate username from email
      userName.value = emailController.text.split('@').first;

      // Simple role detection (can improve later)
      if (emailController.text.toLowerCase().contains('admin')) {
        selectedRole.value = 'Landlord';
      } else {
        selectedRole.value = 'Tenant';
      }

      navToHome();
    } else {
      Get.snackbar('Error', 'Please enter email');
    }
  }

  void register() {
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      userName.value = nameController.text;
      userEmail.value = emailController.text;
      userPhone.value = phoneController.text;
      userAddress.value = addressController.text;

      navToHome();
    } else {
      Get.snackbar('Error', 'Please fill all required fields');
    }
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

  void navToHome() {
    Get.offNamed(AppRoutes.home);
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

  void sendOtp() {
    if (emailController.text.isNotEmpty || phoneController.text.isNotEmpty) {
      Get.offNamed(AppRoutes.verifyOtp);
    } else {
      Get.snackbar('Error', 'Please enter email or phone number');
    }
  }

  void verifyOtp() {
    if (otpController.text.isNotEmpty) {
      Get.offNamed(AppRoutes.resetPassword);
    } else {
      Get.snackbar('Error', 'Please enter OTP');
    }
  }

  void resetPassword() {
    if (newPasswordController.text.isNotEmpty &&
        newPasswordController.text == confirmPasswordController.text) {
      Get.snackbar('Success', 'Your password changed');
      Get.offNamed(AppRoutes.login);
    } else {
      Get.snackbar('Error', 'Passwords do not match or are empty');
    }
  }
}
