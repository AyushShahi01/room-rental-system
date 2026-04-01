import 'package:dio/dio.dart';

class DioConnection {
  static final dio = Dio(
    BaseOptions(
      // baseUrl: "https://codeit.com.np/api/",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );
}
