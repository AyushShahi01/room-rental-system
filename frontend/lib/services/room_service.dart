import 'dart:io';

import 'package:dio/dio.dart';

import '../models/room/common_response_model.dart';
import '../models/room/room_detail_model.dart';
import '../models/room/room_image_model.dart';
import '../models/room/room_model.dart' as room_model;
import '../utils/dio_connection.dart';

class RoomService {
  final Dio _dio = DioConnection.dio;

  Future<room_model.RoomModel> getRooms({Map<String, dynamic>? filters}) async {
    final response = await _dio.get('rooms/', queryParameters: filters);
    return room_model.RoomModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RoomDetailModel> createRoom(Map<String, dynamic> data) async {
    final response = await _dio.post('rooms/', data: data);
    return RoomDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RoomDetailModel> getRoom(int id) async {
    final response = await _dio.get('rooms/$id/');
    return RoomDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RoomDetailModel> updateRoom(int id, Map<String, dynamic> data) async {
    final response = await _dio.put('rooms/$id/', data: data);
    return RoomDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RoomDetailModel> patchRoom(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('rooms/$id/', data: data);
    return RoomDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CommonResponseModel> deleteRoom(int id) async {
    final response = await _dio.delete('rooms/$id/');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return CommonResponseModel.fromJson(data);
    }
    return CommonResponseModel(message: 'Room deleted successfully.');
  }

  Future<CommonResponseModel> toggleAvailability(int id) async {
    final response = await _dio.patch('rooms/$id/availability/');
    return CommonResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RoomImageModel> getRoomImages(int roomId) async {
    final response = await _dio.get('rooms/$roomId/images/');
    return RoomImageModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RoomImageModel> uploadRoomImage(int roomId, File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    final response = await _dio.post(
      'rooms/$roomId/images/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return RoomImageModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<room_model.RoomModel> getMyRooms() async {
    final response = await _dio.get('rooms/my-rooms/');
    return room_model.RoomModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<room_model.RoomModel> getRecommendations(
    Map<String, dynamic> preferences,
  ) async {
    final response = await _dio.post(
      'rooms/recommendations/',
      data: preferences,
    );
    final data = response.data as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              room_model.Result.fromJson(item['room'] as Map<String, dynamic>),
        )
        .toList();

    return room_model.RoomModel(
      count: data['count'] as int? ?? results.length,
      next: null,
      previous: null,
      results: results,
    );
  }
}
