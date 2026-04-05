import 'package:dio/dio.dart';
import 'package:room_rental_system/utils/dio_connection.dart';
import 'package:room_rental_system/controllers/storage_controller.dart';

class PaymentService {
  static Future<Response> processPayment(
    Map<String, dynamic> paymentData,
  ) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.post("payments/", data: paymentData);
  }

  static Future<Response> fetchPaymentHistory() async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.get("payments/history/");
  }

  static Future<Response> verifyPayment(String transactionId) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.post(
      "payments/verify/",
      data: {"transaction_id": transactionId},
    );
  }
}
