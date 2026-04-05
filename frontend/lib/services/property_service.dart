import 'package:dio/dio.dart';
import 'package:room_rental_system/utils/dio_connection.dart';
import 'package:room_rental_system/controllers/storage_controller.dart';

class PropertyService {
  static Future<Response> getProperties({String? filter}) async {
    return await DioConnection.dio.get(
      "properties/",
      queryParameters: filter != null ? {"category": filter} : null,
    );
  }

  static Future<Response> getPropertyDetails(String id) async {
    return await DioConnection.dio.get("properties/$id/");
  }

  static Future<Response> createProperty(
    Map<String, dynamic> propertyData,
  ) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.post("properties/", data: propertyData);
  }

  static Future<Response> updateProperty(
    String id,
    Map<String, dynamic> propertyData,
  ) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.put("properties/$id/", data: propertyData);
  }

  static Future<Response> deleteProperty(String id) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.delete("properties/$id/");
  }
}
