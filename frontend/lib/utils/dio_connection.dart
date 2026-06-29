import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'token_storage.dart';

class DioConnection {
  static final Dio dio = _buildDio();

  static final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: 'https://room-rental-system-f5x8.onrender.com/api/',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://room-rental-system-f5x8.onrender.com/api/',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(_AuthInterceptor(dio));
    return dio;
  }
}

class _AuthInterceptor extends QueuedInterceptorsWrapper {
  _AuthInterceptor(this._dio);

  final Dio _dio;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final path = options.path.toLowerCase();
    final isAuthRequest = path.contains('auth/login') ||
        path.contains('auth/register') ||
        path.contains('auth/refresh');

    if (!isAuthRequest) {
      final token = TokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path.toLowerCase();
    final isAuthRequest = path.contains('auth/login') ||
        path.contains('auth/register') ||
        path.contains('auth/refresh');

    if (err.response?.statusCode != 401 || isAuthRequest) {
      handler.next(err);
      return;
    }

    final refreshToken = TokenStorage.getRefreshToken();
    if (refreshToken == null) {
      await _handleLogout();
      handler.next(err);
      return;
    }

    try {
      final refreshDio = DioConnection._refreshDio;
      final response = await refreshDio.post(
        'auth/refresh/',
        data: {'refresh': refreshToken},
      );

      final newAccess = response.data['access'] as String?;
      if (newAccess == null) {
        await _handleLogout();
        handler.next(err);
        return;
      }

      await TokenStorage.saveAccessToken(newAccess);

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';

      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException {
      await _handleLogout();
      handler.next(err);
    }
  }

  Future<void> _handleLogout() async {
    await TokenStorage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}