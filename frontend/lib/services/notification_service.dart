import 'package:dio/dio.dart';
import '../models/notification/notification_list_model.dart';
import '../models/notification/commonresponsenotification_model.dart';
import '../utils/dio_connection.dart';

class NotificationService {
  final Dio _dio = DioConnection.dio;

  Future<NotificationListModel> getNotifications() async {
    final response = await _dio.get('notifications/');
    return NotificationListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteNotification(int id) async {
    await _dio.delete('notifications/$id/');
  }

  Future<void> markAsRead(int id) async {
    await _dio.patch('notifications/$id/read/');
  }

  Future<CommonResponseNotificationModel> markAllAsRead() async {
    final response = await _dio.patch('notifications/read-all/');
    return CommonResponseNotificationModel.fromJson(response.data as Map<String, dynamic>);
  }
}
