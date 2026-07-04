import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/agreement/agreement_model.dart';
import '../models/agreement/agreement_list_model.dart';
import '../utils/dio_connection.dart';

class AgreementService {
  final Dio _dio = DioConnection.dio;

  Future<AgreementListModel> getAgreements() async {
    final response = await _dio.get('agreements/');
    return AgreementListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AgreementModel> createAgreement(Map<String, dynamic> data) async {
    final response = await _dio.post('agreements/', data: data);
    return AgreementModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AgreementModel> getAgreement(int id) async {
    final url = 'agreements/$id/';
    debugPrint('[AgreementService] GET $url');
    final response = await _dio.get(url);
    debugPrint('[AgreementService] Status: ${response.statusCode}');
    debugPrint('[AgreementService] Parsed Agreement: ${response.data}');
    return AgreementModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AgreementModel> signAgreement(int id) async {
    final url = 'agreements/$id/sign/';
    debugPrint('[AgreementService] PATCH $url');
    final response = await _dio.patch(url);
    debugPrint('[AgreementService] Status: ${response.statusCode}');
    return AgreementModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Backend returns a single agreement object for GET /agreements/booking/{id}/.
  Future<AgreementModel?> getAgreementByBooking(int bookingId) async {
    final url = 'agreements/booking/$bookingId/';
    debugPrint('[AgreementService] Booking ID: $bookingId');
    debugPrint('[AgreementService] API URL: $url');

    final response = await _dio.get(url);
    debugPrint('[AgreementService] HTTP Status: ${response.statusCode}');

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      debugPrint('[AgreementService] Unexpected response type: ${data.runtimeType}');
      return null;
    }

    // Paginated fallback (should not happen for booking endpoint).
    if (data.containsKey('results') && data['results'] is List) {
      final results = data['results'] as List;
      if (results.isEmpty) return null;
      final first = results.first;
      if (first is! Map<String, dynamic>) return null;
      final model = AgreementModel.fromJson(first);
      debugPrint('[AgreementService] Agreement ID: ${model.id}');
      debugPrint('[AgreementService] Parsed Agreement: $model');
      return model;
    }

    final model = AgreementModel.fromJson(data);
    debugPrint('[AgreementService] Agreement ID: ${model.id}');
    debugPrint('[AgreementService] Parsed Agreement: $model');
    return model;
  }
}
