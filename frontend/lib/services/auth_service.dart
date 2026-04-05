import 'package:dio/dio.dart';
import 'package:room_rental_system/utils/dio_connection.dart';
import 'package:room_rental_system/controllers/storage_controller.dart';

class AuthService {
  static Future<Response> register(Map<String, dynamic> data) async {
    return await DioConnection.dio.post(
      "register/",
      data: data,
    );
  }

  static Future<Response> login(String username, String email, String password) async {
    return await DioConnection.dio.post(
      "login/",
      data: {
        "username": username,
        "email": email,
        "password": password
      },
    );
  }

  static Future<Response> logout(String refreshToken) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.post(
      "logout/",
      data: {"refresh": refreshToken},
    );
  }

  static Future<Response> refreshToken(String refreshToken) async {
    return await DioConnection.dio.post(
      "refresh/",
      data: {"refresh": refreshToken},
    );
  }

  static Future<Response> fetchProfile() async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.get("me/");
  }

  static Future<Response> verifyEmail(String email, String otpCode) async {
    return await DioConnection.dio.post(
      "verify-email/",
      data: {"email": email, "otp_code": otpCode},
    );
  }

  static Future<Response> resendVerification(String email) async {
    return await DioConnection.dio.post(
      "resend-verification/",
      data: {"email": email},
    );
  }

  static Future<Response> forgotPassword(String email) async {
    return await DioConnection.dio.post(
      "forgot-password/",
      data: {"email": email},
    );
  }

  static Future<Response> resetPassword(
    String email,
    String otpCode,
    String newPassword,
  ) async {
    return await DioConnection.dio.post(
      "reset-password/",
      data: {"email": email, "otp_code": otpCode, "new_password": newPassword},
    );
  }

  static Future<Response> changePassword(
    String oldPassword,
    String newPassword,
    String newPasswordConfirm,
  ) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.post(
      "change-password/",
      data: {
        "old_password": oldPassword,
        "new_password": newPassword,
        "new_password_confirm": newPasswordConfirm,
      },
    );
  }
}
