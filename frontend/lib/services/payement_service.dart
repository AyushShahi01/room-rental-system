import 'package:dio/dio.dart';

import '../models/payement/payement_model.dart';
import '../models/payement/payement_list_model.dart';
import '../models/payement/rent_record_model.dart';
import '../models/payement/rent_dashboard_model.dart';
import '../utils/dio_connection.dart';

class PaymentService {
  final Dio _dio = DioConnection.dio;

  Future<PaymentListModel> getPayments() async {
    final response = await _dio.get('payments/');
    return PaymentListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentModel> createPayment(Map<String, dynamic> data) async {
    final response = await _dio.post('payments/', data: data);
    return PaymentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentModel> getPayment(int id) async {
    final response = await _dio.get('payments/$id/');
    return PaymentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentModel> verifyPayment(int id) async {
    final response = await _dio.patch('payments/$id/verify/');
    return PaymentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentListModel> getPaymentsByBooking(int bookingId) async {
    final response = await _dio.get('payments/booking/$bookingId/');
    return PaymentListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentListModel> getPaymentHistory() async {
    final response = await _dio.get('payments/history/');
    return PaymentListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PaymentListModel> getMyPayments() async {
    final response = await _dio.get('payments/my-payments/');
    return PaymentListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> verifyKhaltiPayment(Map<String, dynamic> data) async {
    final response = await _dio.post('payments/khalti/verify/', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyEsewaPayment(Map<String, dynamic> data) async {
    final response = await _dio.post('payments/esewa/verify/', data: data);
    return response.data as Map<String, dynamic>;
  }

  // Rent Records & Dashboard APIs
  Future<RentDashboardModel> getRentDashboard() async {
    final response = await _dio.get('rent/dashboard/');
    return RentDashboardModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<RentRecordModel>> getRentRecords({Map<String, dynamic>? params}) async {
    final response = await _dio.get('rent/', queryParameters: params);
    final data = response.data;
    if (data is Map<String, dynamic> && data['results'] != null) {
      final list = data['results'] as List<dynamic>? ?? [];
      return list.map((e) => RentRecordModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (data is List) {
      return data.map((e) => RentRecordModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<RentRecordModel> updateRentRecordStatus(int id, String status) async {
    final response = await _dio.patch('rent/$id/', data: {'status': status});
    return RentRecordModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RentRecordModel> patchRentRecord(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('rent/$id/', data: data);
    return RentRecordModel.fromJson(response.data as Map<String, dynamic>);
  }
}

