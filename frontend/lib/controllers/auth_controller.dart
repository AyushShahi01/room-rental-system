import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';


class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final RxString userName = 'Guest'.obs;
  final RxString userEmail = ''.obs;
  final RxString selectedRole = 'Tenant'.obs;

  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isRegisterPasswordVisible = false.obs;

  // Mock users list for Admin view
  final RxList<Map<String, String>> mockUsers = <Map<String, String>>[
    {'name': 'Alice Smith', 'email': 'alice@example.com', 'role': 'Tenant'},
    {'name': 'Bob Johnson', 'email': 'bob@example.com', 'role': 'Tenant'},
    {'name': 'Admin User', 'email': 'admin@system.com', 'role': 'Admin'},
  ].obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void login() {
    if (emailController.text.isNotEmpty) {
      userEmail.value = emailController.text;
      if (userName.value == 'Guest') {
        userName.value = emailController.text.split('@').first;
      }
      // Assuming Admin if login email contains 'admin'
      if (emailController.text.toLowerCase().contains('admin')) {
        selectedRole.value = 'Admin';
      }
    }
    navToHome();
  }

  void register() {
    if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
      userName.value = nameController.text;
      userEmail.value = emailController.text;
      
      // Add the newly registered user to the mock users list
      mockUsers.add({
        'name': nameController.text,
        'email': emailController.text,
        'role': selectedRole.value,
        if (selectedRole.value == 'Tenant') 'phone': phoneController.text,
        if (selectedRole.value == 'Tenant') 'address': addressController.text,
      });
    }
    navToHome();
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible.value = !isRegisterPasswordVisible.value;
  }

  void navToHome() {
    Get.offAllNamed(AppRoutes.home);
  }

  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }
}

