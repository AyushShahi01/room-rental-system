import 'package:dio/dio.dart';
import '../models/auth_model/login_model.dart';
import '../models/auth_model/register_model.dart';
import '../models/auth_model/refresh_model.dart';
import '../utils/dio_connection.dart';

class AuthService {
  final Dio _dio = DioConnection.dio;

  Future<LoginModel> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final input = usernameOrEmail.trim();
    final Map<String, dynamic> body = {
      'password': password,
    };

    if (input.contains('@')) {
      body['email'] = input;
    } else {
      body['username'] = input.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    }

    final response = await _dio.post(
      'auth/login/',
      data: body,
    );
    return LoginModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RegisterModel> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? province,
    String? district,
    String? city,
    String? ward,
  }) async {
    final sanitizedUsername = username.replaceAll(RegExp(r'\s+'), '').toLowerCase();

    final Map<String, dynamic> body = {
      'username': sanitizedUsername,
      'email': email.trim(),
      'password': password,
      'role': role,
    };

    if (province != null && province.isNotEmpty) body['province'] = province;
    if (district != null && district.isNotEmpty) body['district'] = district;
    if (city != null && city.isNotEmpty) body['city'] = city;
    if (ward != null && ward.isNotEmpty) {
      body['ward'] = int.tryParse(ward) ?? ward;
    }

    final response = await _dio.post(
      'auth/register/',
      data: body,
    );
    return RegisterModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RefreshModel> refresh({required String refreshToken}) async {
    final response = await _dio.post(
      'auth/refresh/',
      data: {'refresh': refreshToken},
    );
    return RefreshModel.fromJson(response.data as Map<String, dynamic>);
  }
}
