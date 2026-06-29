import 'package:get_storage/get_storage.dart';

class TokenStorage {
  static final _box = GetStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static String? getAccessToken() => _box.read<String>(_accessKey);

  static String? getRefreshToken() => _box.read<String>(_refreshKey);

  static bool get hasTokens =>
      getAccessToken() != null && getRefreshToken() != null;

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _box.write(_accessKey, accessToken);
    await _box.write(_refreshKey, refreshToken);
  }

  static Future<void> saveAccessToken(String accessToken) async {
    await _box.write(_accessKey, accessToken);
  }

  static Future<void> clearAll() async {
    await _box.remove(_accessKey);
    await _box.remove(_refreshKey);
  }
}
