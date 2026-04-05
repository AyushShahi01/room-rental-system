import 'package:dio/dio.dart';
import 'package:room_rental_system/utils/dio_connection.dart';
import 'package:room_rental_system/controllers/storage_controller.dart';

class MaintenanceService {
  static Future<Response> createRequest(
    Map<String, dynamic> requestData,
  ) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.post("maintenance/", data: requestData);
  }

  static Future<Response> fetchRequests() async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.get("maintenance/");
  }

  static Future<Response> updateStatus(String requestId, String status) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.put(
      "maintenance/$requestId/status/",
      data: {"status": status},
    );
  }
}
