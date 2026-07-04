import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';
import '../models/auth_model/user_model.dart';

class AuthController extends GetxController {
  final _authService = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final provinceController = TextEditingController();
  final districtController = TextEditingController();
  final cityController = TextEditingController();
  final wardController = TextEditingController();

  // Profile edit controllers
  final editFirstNameController = TextEditingController();
  final editLastNameController = TextEditingController();
  final editProvinceController = TextEditingController();
  final editDistrictController = TextEditingController();
  final editCityController = TextEditingController();
  final editWardController = TextEditingController();

  // Change password controllers
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isOldPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  final RxString userName = 'Guest'.obs;
  final RxString userEmail = ''.obs;
  final RxString selectedRole = 'tenant'.obs;

  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isRegisterPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isFetchingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (TokenStorage.hasTokens) {
      fetchCurrentUser();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    provinceController.dispose();
    districtController.dispose();
    cityController.dispose();
    wardController.dispose();

    editFirstNameController.dispose();
    editLastNameController.dispose();
    editProvinceController.dispose();
    editDistrictController.dispose();
    editCityController.dispose();
    editWardController.dispose();

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> fetchCurrentUser() async {
    try {
      isFetchingProfile.value = true;
      final user = await _authService.getMe();
      currentUser.value = user;

      userName.value = user.username ?? 'Guest';
      userEmail.value = user.email ?? '';
      selectedRole.value = user.role ?? 'tenant';

      editFirstNameController.text = user.firstName ?? '';
      editLastNameController.text = user.lastName ?? '';
      editProvinceController.text = user.province ?? '';
      editDistrictController.text = user.district ?? '';
      editCityController.text = user.city ?? '';
      editWardController.text = user.ward != null ? user.ward.toString() : '';
    } on DioException catch (e) {
      final message = _extractMessage(e) ?? 'Failed to fetch user profile.';
      debugPrint('fetchCurrentUser error: $message');
    } catch (e) {
      debugPrint('fetchCurrentUser error: $e');
    } finally {
      isFetchingProfile.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (isLoading.value) return;

    final firstName = editFirstNameController.text.trim();
    final lastName = editLastNameController.text.trim();
    final province = editProvinceController.text.trim();
    final district = editDistrictController.text.trim();
    final city = editCityController.text.trim();
    final wardText = editWardController.text.trim();

    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'province': province,
      'district': district,
      'city': city,
    };

    if (wardText.isNotEmpty) {
      final parsedWard = int.tryParse(wardText);
      if (parsedWard != null) {
        data['ward'] = parsedWard;
      } else {
        _showError('Validation Error', 'Ward must be a positive integer.');
        return;
      }
    } else {
      data['ward'] = null;
    }

    try {
      isLoading.value = true;
      final user = await _authService.updateMe(data);
      currentUser.value = user;

      userName.value = user.username ?? 'Guest';
      userEmail.value = user.email ?? '';
      selectedRole.value = user.role ?? 'tenant';

      Get.snackbar(
        'Profile Updated',
        'Your changes have been saved successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      await Future.delayed(const Duration(milliseconds: 800));
      Get.back();
    } on DioException catch (e) {
      final message =
          _extractMessage(e) ?? 'Profile update failed. Please try again.';
      _showError('Update Failed', message);
    } catch (e) {
      _showError('Error', 'An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    if (isLoading.value) return;

    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError('Validation Error', 'All password fields are required.');
      return;
    }

    if (newPassword.length < 8) {
      _showError(
        'Validation Error',
        'New password must be at least 8 characters long.',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Validation Error', 'New passwords do not match.');
      return;
    }

    try {
      isLoading.value = true;
      final result = await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirm: confirmPassword,
      );

      final message = result['message'] ?? 'Password changed successfully.';
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );

      clearPasswordForm();
      Get.back();
    } on DioException catch (e) {
      final message =
          _extractMessage(e) ?? 'Failed to change password. Please try again.';
      _showError('Change Password Failed', message);
    } catch (e) {
      _showError('Error', 'An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
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
        _showError(
          'Login Failed',
          'Server did not return tokens. Please try again.',
        );
        return;
      }

      await TokenStorage.saveTokens(accessToken: access, refreshToken: refresh);

      userName.value = result.user?.username ?? input.split('@').first;
      userEmail.value = result.user?.email ?? input;
      if (result.user != null) {
        final u = result.user!;
        currentUser.value = UserModel.fromJson(u.toJson());
        selectedRole.value = u.role ?? 'tenant';
        editFirstNameController.text = u.firstName ?? '';
        editLastNameController.text = u.lastName ?? '';
        editProvinceController.text = u.province ?? '';
        editDistrictController.text = u.district ?? '';
        editCityController.text = u.city ?? '';
        editWardController.text = u.ward?.toString() ?? '';
      }

      navToHome();
    } on DioException catch (e) {
      final backendMessage = _extractMessage(e);
      if (backendMessage != null) {
        _showError('Login Failed', backendMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        _showError(
          'Connection Timeout',
          'The server took too long to respond. Please check your internet connection and try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        _showError(
          'No Connection',
          'Unable to reach the server. Please check your internet connection.',
        );
      } else if ((e.response?.statusCode ?? 0) >= 500) {
        _showError(
          'Server Error',
          'The server encountered an error. Please try again later.',
        );
      } else {
        _showError(
          'Login Failed',
          'Login failed. Please check your credentials and try again.',
        );
      }
    } catch (e) {
      _showError('Error', 'An unexpected error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (isLoading.value) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final province = provinceController.text.trim();
    final district = districtController.text.trim();
    final city = cityController.text.trim();
    final wardText = wardController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Validation', 'Name, email and password are required.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showError('Validation', 'Please enter a valid email address.');
      return;
    }

    if (password.length < 8) {
      _showError('Validation', 'Password must be at least 8 characters long.');
      return;
    }

    if (selectedRole.value == 'landlord') {
      if (province.isEmpty ||
          district.isEmpty ||
          city.isEmpty ||
          wardText.isEmpty) {
        _showError(
          'Validation',
          'Province, district, city and ward are required for landlords.',
        );
        return;
      }
      final wardNumber = int.tryParse(wardText);
      if (wardNumber == null || wardNumber <= 0) {
        _showError('Validation', 'Ward must be a positive number.');
        return;
      }
    }

    final username = _buildUsername(name, email);
    final nameParts = _splitName(name);

    try {
      isLoading.value = true;

      final result = await _authService.register(
        username: username,
        firstName: nameParts.first,
        lastName: nameParts.last,
        email: email,
        password: password,
        role: selectedRole.value,
        province: province,
        district: district,
        city: city,
        ward: wardText,
      );

      final access = result.tokens?.access;
      final refresh = result.tokens?.refresh;
      if (access == null || refresh == null) {
        _showError(
          'Registration Failed',
          'Server did not return tokens. Please try again.',
        );
        return;
      }

      await TokenStorage.saveTokens(accessToken: access, refreshToken: refresh);

      userName.value = result.user?.username ?? username;
      userEmail.value = result.user?.email ?? email;
      if (result.user != null) {
        final u = result.user!;
        currentUser.value = UserModel.fromJson(u.toJson());
        editFirstNameController.text = u.firstName ?? '';
        editLastNameController.text = u.lastName ?? '';
        editProvinceController.text = u.province ?? '';
        editDistrictController.text = u.district ?? '';
        editCityController.text = u.city ?? '';
        editWardController.text = (u.ward as dynamic)?.toString() ?? '';
      }

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
      final message =
          _extractMessage(e) ?? 'Registration failed. Please try again.';
      _showError('Registration Failed', message);
    } catch (e) {
      _showError('Error', 'An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _buildUsername(String name, String email) {
    final source = name.isNotEmpty ? name : email.split('@').first;
    final sanitized = source
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^\w.@+-]'), '');

    if (sanitized.isEmpty) {
      return email.split('@').first.toLowerCase();
    }
    return sanitized;
  }

  _NameParts _splitName(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return _NameParts(first: '', last: '');
    }
    if (parts.length == 1) {
      return _NameParts(first: parts.first, last: '');
    }
    return _NameParts(first: parts.first, last: parts.sublist(1).join(' '));
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible.value = !isRegisterPasswordVisible.value;
  }

  void toggleOldPasswordVisibility() {
    isOldPasswordVisible.value = !isOldPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void navToHome() {
    final role = selectedRole.value.toLowerCase();
    if (role == 'admin' || role == 'landlord') {
      Get.offAllNamed(AppRoutes.landlordDashboard);
    } else {
      Get.offAllNamed(AppRoutes.tenantDashboard);
    }
  }

  void goToLogin() => Get.toNamed(AppRoutes.login);
  void goToRegister() => Get.toNamed(AppRoutes.register);

  Future<void> logout() async {
    final refreshToken = TokenStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        isLoading.value = true;
        await _authService.logout(refreshToken: refreshToken);
      } catch (e) {
        debugPrint('Logout API failed: $e');
      } finally {
        isLoading.value = false;
      }
    }

    await TokenStorage.clearAll();
    userName.value = 'Guest';
    userEmail.value = '';
    currentUser.value = null;
    clearRegisterForm();
    clearPasswordForm();
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

  void clearPasswordForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    isOldPasswordVisible.value = false;
    isNewPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
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
        // Top-level shorthand keys
        final topLevel = data['detail'] ?? data['message'] ?? data['error'];
        if (topLevel != null) return topLevel.toString();

        // Backend login/register errors come wrapped in: {"errors": {...}}
        final errorsMap = data['errors'];
        if (errorsMap is Map) {
          // non_field_errors is the most relevant — show it first
          final nonField = errorsMap['non_field_errors'];
          if (nonField is List && nonField.isNotEmpty) {
            return nonField.join('\n');
          }
          // Fall back to all field-level messages
          final parts = <String>[];
          for (final entry in errorsMap.entries) {
            final val = entry.value;
            if (val is List) {
              parts.add(val.join(', '));
            } else if (val is String) {
              parts.add(val);
            }
          }
          if (parts.isNotEmpty) return parts.join('\n');
        }

        // Generic field-level errors at top level
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
      // String body (rare)
      if (data is String && data.isNotEmpty) return data;
    } catch (_) {}
    return null;
  }
}

class _NameParts {
  final String first;
  final String last;

  _NameParts({required this.first, required this.last});
}
