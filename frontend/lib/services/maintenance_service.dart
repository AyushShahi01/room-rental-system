import 'package:dio/dio.dart';
import '../models/maintenace/maintenance_model.dart';
import '../models/maintenace/maintenace_list_model.dart';
import '../utils/dio_connection.dart';

class MaintenanceService {
  final Dio _dio = DioConnection.dio;

  Future<MaintenanceListModel> getAllMaintenance() async {
    final response = await _dio.get('maintenance/');
    return MaintenanceListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MaintenanceModel> createMaintenance({
    required int room,
    required String description,
    String? imagePath,
  }) async {
    final Map<String, dynamic> data = {
      'room': room,
      'description': description,
    };

    if (imagePath != null && imagePath.isNotEmpty) {
      final fileName = imagePath.split('/').last.split('\\').last;
      data['image'] = await MultipartFile.fromFile(imagePath, filename: fileName);
    }

    final formData = FormData.fromMap(data);

    final response = await _dio.post(
      'maintenance/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return MaintenanceModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MaintenanceModel> getMaintenanceById(int id) async {
    final response = await _dio.get('maintenance/$id/');
    return MaintenanceModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MaintenanceModel> updateMaintenanceStatus(int id, String status) async {
    final response = await _dio.patch(
      'maintenance/$id/status/',
      data: {'status': status},
    );
    return MaintenanceModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MaintenanceListModel> getMyMaintenanceRequests() async {
    final response = await _dio.get('maintenance/my-requests/');
    return MaintenanceListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MaintenanceListModel> getMaintenanceByRoom(int roomId) async {
    final response = await _dio.get('maintenance/room/$roomId/');
    return MaintenanceListModel.fromJson(response.data as Map<String, dynamic>);
  }
}
