import 'package:dio/dio.dart';

class DioConnection {
  static final dio = Dio(
    BaseOptions(
      baseUrl: "https://honors-sentence-representation-decent.trycloudflare.com/api/",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );
}