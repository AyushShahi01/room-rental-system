import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/payement/payement_model.dart';
import '../services/payement_service.dart';
import 'booking_controller.dart';
import 'room_controller.dart';

class PaymentController extends GetxController {
  final PaymentService _service = PaymentService();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSuccess = false.obs;
  final RxString successMessage = ''.obs;
  
  final RxList<dynamic> myPayments = <dynamic>[].obs;
  final RxList<dynamic> paymentHistory = <dynamic>[].obs;
  
  Future<void> loadMyPayments({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';
      final data = await _service.getMyPayments();
      myPayments.assignAll(data.results);
    } catch (e) {
      errorMessage.value = 'Failed to load your payments.';
      debugPrint('Error loading my payments: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> loadPaymentHistory({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';
      final data = await _service.getPaymentHistory();
      paymentHistory.assignAll(data.results);
    } catch (e) {
      errorMessage.value = 'Failed to load payment history.';
      debugPrint('Error loading payment history: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> processPayment({
    required int bookingId,
    required String amount,
    required String gateway,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      isSuccess.value = false;
      successMessage.value = '';

      // 1. Create Payment Record
      final paymentData = {
        'booking': bookingId,
        'amount': amount,
        'payment_gateway': gateway,
      };
      
      final payment = await _service.createPayment(paymentData);
      
      // Gateway initialization is missing on the backend.
      // We cannot securely obtain the pidx (Khalti) or transaction_uuid (eSewa).
      throw Exception(
          'Missing Backend Gateway Initialization endpoint (e.g., POST /payments/${gateway.toLowerCase()}/initiate/). '
          'The frontend cannot securely obtain the pidx/transaction_uuid required for verification.');
    } catch (e) {
      String err = 'Payment processing failed. Please try again.';
      if (e is DioException && e.response?.data != null) {
        if (e.response!.data is Map) {
          err = (e.response!.data as Map).values.join(', ');
        } else {
          err = e.response!.data.toString();
        }
      } else if (e is Exception) {
        err = e.toString().replaceFirst('Exception: ', '');
      }
      errorMessage.value = err;
      debugPrint('Error processing payment: $e');
      Get.snackbar(
        'Error',
        err,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
