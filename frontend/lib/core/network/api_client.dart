import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:room_rental_system/core/routes/app_routes.dart';
import 'package:room_rental_system/core/storage/token_storage.dart';

class ApiClient extends GetxService {
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _init();
  }

  late final Dio dio;

  String _getBaseUrl() {
    var baseUrl = dotenv.env['BASE_URL'] ?? 'https://room-rental-system-f5x8.onrender.com/api/';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = baseUrl.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
    }
    return baseUrl;
  }

  void _init() {
    final baseUrl = _getBaseUrl();

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Access token handler
          final token = getAccessToken();
          if (token != null && !_isAuthRequest(options.path)) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (err, handler) async {
          // Refresh token handler
          if (err.response?.statusCode != 401 || _isAuthRequest(err.requestOptions.path)) {
            return handler.next(err);
          }

          final refreshedToken = await handleTokenRefresh();
          if (refreshedToken != null) {
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $refreshedToken';

            try {
              final retryResponse = await dio.fetch(retryOptions);
              return handler.resolve(retryResponse);
            } catch (e) {
              return handler.next(err);
            }
          }

          return handler.next(err);
        },
      ),
    );
  }

  bool _isAuthRequest(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.contains('auth/login') ||
        lowerPath.contains('auth/register') ||
        lowerPath.contains('auth/refresh');
  }

  // Access Token Handler
  String? getAccessToken() {
    return TokenStorage.getAccessToken();
  }

  // Refresh Token Handler
  Future<String?> handleTokenRefresh() async {
    final refreshToken = TokenStorage.getRefreshToken();
    if (refreshToken == null) {
      await _handleLogout();
      return null;
    }

    try {
      final baseUrl = _getBaseUrl();
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        'auth/refresh/',
        data: {'refresh': refreshToken},
      );

      final newAccess = response.data['access'] as String?;
      if (newAccess != null) {
        await TokenStorage.saveAccessToken(newAccess);
        return newAccess;
      }
    } catch (e) {
      // Failed to refresh token
    }

    await _handleLogout();
    return null;
  }

  Future<void> _handleLogout() async {
    await TokenStorage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }

  // --- HTTP GET Request ---
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return await dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // --- HTTP POST Request ---
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return await dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // --- HTTP PATCH Request ---
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return await dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // --- HTTP DELETE Request ---
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // --- HTTP Multipart POST Request ---
  Future<Response<T>> postMultipart<T>(
    String path, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? files, // key -> String path OR List<String> paths
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final formDataMap = Map<String, dynamic>.from(data);

    if (files != null) {
      for (final entry in files.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value is String && value.isNotEmpty) {
          final file = File(value);
          if (await file.exists()) {
            formDataMap[key] = await MultipartFile.fromFile(
              value,
              filename: value.split('/').last,
            );
          }
        } else if (value is List<String>) {
          final multipartFiles = <MultipartFile>[];
          for (final path in value) {
            if (path.isNotEmpty) {
              final file = File(path);
              if (await file.exists()) {
                multipartFiles.add(await MultipartFile.fromFile(
                  path,
                  filename: path.split('/').last,
                ));
              }
            }
          }
          if (multipartFiles.isNotEmpty) {
            formDataMap[key] = multipartFiles;
          }
        }
      }
    }

    final formData = FormData.fromMap(formDataMap);

    return await dio.post<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options ?? Options(contentType: 'multipart/form-data'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // --- HTTP Multipart PATCH Request ---
  Future<Response<T>> patchMultipart<T>(
    String path, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? files, // key -> String path OR List<String> paths
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final formDataMap = Map<String, dynamic>.from(data);

    if (files != null) {
      for (final entry in files.entries) {
        final key = entry.key;
        final value = entry.value;
        if (value is String && value.isNotEmpty) {
          final file = File(value);
          if (await file.exists()) {
            formDataMap[key] = await MultipartFile.fromFile(
              value,
              filename: value.split('/').last,
            );
          }
        } else if (value is List<String>) {
          final multipartFiles = <MultipartFile>[];
          for (final path in value) {
            if (path.isNotEmpty) {
              final file = File(path);
              if (await file.exists()) {
                multipartFiles.add(await MultipartFile.fromFile(
                  path,
                  filename: path.split('/').last,
                ));
              }
            }
          }
          if (multipartFiles.isNotEmpty) {
            formDataMap[key] = multipartFiles;
          }
        }
      }
    }

    final formData = FormData.fromMap(formDataMap);

    return await dio.patch<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options ?? Options(contentType: 'multipart/form-data'),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
