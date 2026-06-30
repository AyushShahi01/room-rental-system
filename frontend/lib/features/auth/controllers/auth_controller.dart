import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/core/routes/app_routes.dart';
import 'package:room_rental_system/features/auth/services/auth_service.dart';
import 'package:room_rental_system/core/storage/token_storage.dart';

class AuthController extends GetxController {
  final _authService = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final cityController = TextEditingController();
  final wardController = TextEditingController();

  final RxString userName = 'Guest'.obs;
  final RxString userEmail = ''.obs;
  final RxString selectedRole = 'tenant'.obs;

  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isRegisterPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    provinceController.dispose();
    districtController.dispose();
    cityController.dispose();
    wardController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (isLoading.value) return;

    final input = emailController.text.trim();
    final password = passwordController.text;

    if (input.isEmpty || password.isEmpty) {
      _showError('Validation', 'Username/Email and password are required.');
      return;
    }

    try {
      isLoading.value = true;

      final result = await _authService.login(
        usernameOrEmail: input,
        password: password,
      );

      final access = result.tokens?.access;
      final refresh = result.tokens?.refresh;
      if (access == null || refresh == null) {
        _showError('Login Failed', 'Server did not return tokens. Please try again.');
        return;
      }

      await TokenStorage.saveTokens(
        accessToken: access,
        refreshToken: refresh,
      );

      userName.value = result.user?.username ?? input.split('@').first;
      userEmail.value = result.user?.email ?? input;

      navToHome();
    } on DioException catch (e) {
      final message = _extractMessage(e) ?? 'Login failed. Please try again.';
      _showError('Login Failed', message);
    } catch (e) {
      _showError('Error', 'An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (isLoading.value) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Validation', 'Name, email and password are required.');
      return;
    }

    try {
      isLoading.value = true;

      final result = await _authService.register(
        username: name,
        email: email,
        password: password,
        role: selectedRole.value,
        province: provinceController.text.trim(),
        district: districtController.text.trim(),
        city: cityController.text.trim(),
        ward: wardController.text.trim(),
      );

      final access = result.tokens?.access;
      final refresh = result.tokens?.refresh;
      if (access == null || refresh == null) {
        _showError('Registration Failed', 'Server did not return tokens. Please try again.');
        return;
      }

      await TokenStorage.saveTokens(
        accessToken: access,
        refreshToken: refresh,
      );

      userName.value = result.user?.username ?? name;
      userEmail.value = result.user?.email ?? email;

      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          'Success',
          result.message ?? 'Registration successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      }

      navToHome();
    } on DioException catch (e) {
      final message = _extractMessage(e) ?? 'Registration failed. Please try again.';
      _showError('Registration Failed', message);
    } catch (e) {
      _showError('Error', 'An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible.value = !isRegisterPasswordVisible.value;
  }

  void navToHome() => Get.offAllNamed(AppRoutes.home);
  void goToLogin() => Get.toNamed(AppRoutes.login);
  void goToRegister() => Get.toNamed(AppRoutes.register);

  Future<void> logout() async {
    await TokenStorage.clearAll();
    userName.value = 'Guest';
    userEmail.value = '';
    clearRegisterForm();
    Get.offAllNamed(AppRoutes.login);
  }

  void clearRegisterForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    provinceController.clear();
    districtController.clear();
    cityController.clear();
    wardController.clear();
    selectedRole.value = 'tenant';
  }

  void _showError(String title, String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
    );
  }

  String? _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        final topLevel = data['detail'] ?? data['message'] ?? data['error'];
        if (topLevel != null) return topLevel.toString();

        final parts = <String>[];
        for (final entry in data.entries) {
          final val = entry.value;
          if (val is List) {
            parts.add('${entry.key}: ${val.join(', ')}');
          } else if (val is String) {
            parts.add('${entry.key}: $val');
          }
        }
        if (parts.isNotEmpty) return parts.join('\n');
      }
    } catch (_) {}
    return null;
  }
}
