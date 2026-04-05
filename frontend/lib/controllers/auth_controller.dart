import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
// import '../services/auth_service.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController(); // Register username
  final loginUsernameController = TextEditingController(); // Login username
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  
  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final cityController = TextEditingController();
  final wardController = TextEditingController();

  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxString userName = 'Guest'.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userAddress = ''.obs;

  final RxString selectedRole = 'tenant'.obs;
  final RxBool isLoading = false.obs;

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

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = loginUsernameController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter username, email, and password');
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

    isLoading.value = true;
    try {
      /* 
      var res = await AuthService.login(username, email, password);
      if (res.statusCode == 200 || res.statusCode == 201) {
        userEmail.value = email;
        userName.value = username;
        navToHome();
      } else {
        Get.snackbar('Error', 'Login failed');
      }
      */
      
      // Simulate backend delay and success
      await Future.delayed(const Duration(seconds: 1));
      userEmail.value = email;
      userName.value = username;
      navToHome();
      
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
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

    isLoading.value = true;
    try {
      Map<String, dynamic> payload = {
        "username": name,
        "email": email,
        "password": password,
        "role": selectedRole.value.toLowerCase(),
      };

      if (selectedRole.value == 'landlord') {
        payload["province"] = provinceController.text.trim().isEmpty ? "Bagmati" : provinceController.text.trim();
        payload["district"] = districtController.text.trim().isEmpty ? "Kathmandu" : districtController.text.trim();
        payload["city"] = cityController.text.trim().isEmpty ? "Kathmandu" : cityController.text.trim();
        payload["ward"] = int.tryParse(wardController.text.trim()) ?? 10;
      }

      /*
      var res = await AuthService.register(payload);
      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('Success', 'Registration successful!');
        userName.value = name;
        userEmail.value = email;
        navToHome();
      } else {
        Get.snackbar('Error', 'Failed to register. Please try again.');
      }
      */

      // Simulate backend delay and success
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar('Success', 'Registration successful!');
      userName.value = name;
      userEmail.value = email;
      navToHome();
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to register: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navToHome() {
    if (selectedRole.value == 'landlord') {
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
