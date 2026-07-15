import 'package:dio/dio.dart';

import '../models/auth_model/commonresponse_auth_model.dart';
import '../models/auth_model/landlord_dash_model.dart';
import '../models/auth_model/login_model.dart';
import '../models/auth_model/logout_model.dart';
import '../models/auth_model/refresh_model.dart';
import '../models/auth_model/register_model.dart';
import '../models/auth_model/user_model.dart';
import '../utils/dio_connection.dart';

class AuthService {
  final Dio _dio = DioConnection.dio;

  Future<LoginModel> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final input = usernameOrEmail.trim();
    final Map<String, dynamic> body = {'password': password};

    if (input.contains('@')) {
      body['email'] = input;
    } else {
      body['username'] = input.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    }

    final response = await _dio.post('auth/login/', data: body);
    return LoginModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RegisterModel> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? province,
    String? district,
    String? city,
    String? ward,
  }) async {
    final sanitizedUsername = username
        .replaceAll(RegExp(r'\s+'), '')
        .toLowerCase();

    final Map<String, dynamic> body = {
      'username': sanitizedUsername,
      'email': email.trim(),
      'password': password,
      'role': role,
    };

    if (firstName != null && firstName.isNotEmpty) {
      body['first_name'] = firstName.trim();
    }
    if (lastName != null && lastName.isNotEmpty) {
      body['last_name'] = lastName.trim();
    }
    if (province != null && province.isNotEmpty) body['province'] = province;
    if (district != null && district.isNotEmpty) body['district'] = district;
    if (city != null && city.isNotEmpty) body['city'] = city;
    if (ward != null && ward.isNotEmpty) {
      body['ward'] = int.tryParse(ward) ?? ward;
    }

    final response = await _dio.post('auth/register/', data: body);
    return RegisterModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RefreshModel> refresh({required String refreshToken}) async {
    final response = await _dio.post(
      'auth/refresh/',
      data: {'refresh': refreshToken},
    );

    return RefreshModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LogoutModel> logout({required String refreshToken}) async {
    final response = await _dio.post(
      'auth/logout/',
      data: {'refresh': refreshToken},
    );

    return LogoutModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get('auth/me/');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateMe(Map<String, dynamic> data) async {
    final response = await _dio.put('auth/me/', data: data);

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> uploadProfilePicture({required String filePath}) async {
    final formData = FormData.fromMap({
      'profile_picture': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(
      'auth/me/profile-picture/',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getMeUpdate() async {
    final response = await _dio.get('auth/me/update/');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateMeUpdate(Map<String, dynamic> data) async {
    final response = await _dio.put('auth/me/update/', data: data);

    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateDeviceToken({required String fcmToken}) async {
    await _dio.post('auth/device-token/', data: {'fcm_token': fcmToken});
  }

  // ================= OTP & PASSWORD RESET =================

  /// POST /api/auth/forgot-password/
  Future<CommonResponseAuthModel> requestPasswordReset(String email) async {
    final response = await _dio.post(
      'auth/forgot-password/',
      data: {'email': email.trim()},
    );

    return CommonResponseAuthModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// POST /api/auth/otp/send/
  Future<CommonResponseAuthModel> sendOtp({required String email}) async {
    final response = await _dio.post(
      'auth/otp/send/',
      data: {'email': email.trim()},
    );

    return CommonResponseAuthModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// POST /api/auth/otp/verify/
  Future<CommonResponseAuthModel> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await _dio.post(
      'auth/otp/verify/',
      data: {'email': email.trim(), 'otp_code': otpCode.trim()},
    );

    return CommonResponseAuthModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// POST /api/auth/reset-password/
  Future<CommonResponseAuthModel> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    final response = await _dio.post(
      'auth/reset-password/',
      data: {
        'email': email.trim(),
        'otp_code': otpCode.trim(),
        'new_password': newPassword,
      },
    );

    return CommonResponseAuthModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final response = await _dio.post(
      'auth/change-password/',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  // ───────────────── Admin / Landlord Endpoints ─────────────────

  /// GET /api/auth/admin/dashboard/
  Future<Map<String, dynamic>> getAdminStats() async {
    final response = await _dio.get('auth/admin/dashboard/');
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/auth/admin/dashboard/
  Future<LandlordDashModel> getLandlordDashboard() async {
    final response = await _dio.get('auth/admin/dashboard/');
    return LandlordDashModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/auth/admin/users/
  Future<Map<String, dynamic>> getLandlordUsers() async {
    final response = await _dio.get('auth/admin/users/');
    return response.data as Map<String, dynamic>;
  }

  /// PATCH /api/auth/admin/users/{id}/ban/
  Future<Map<String, dynamic>> banUser(String userId) async {
    final response = await _dio.patch('auth/admin/users/$userId/ban/');

    return response.data as Map<String, dynamic>;
  }
}
