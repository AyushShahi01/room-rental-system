import 'package:dio/dio.dart';
import 'package:room_rental_system/core/network/api_client.dart';

class DioConnection {
  static Dio get dio => ApiClient().dio;
}
