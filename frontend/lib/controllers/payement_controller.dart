import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/payement/payement_model.dart';
import '../models/payement/rent_record_model.dart';
import '../models/payement/rent_dashboard_model.dart';
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

  // Rent Records & Dashboard states
  final Rxn<RentDashboardModel> rentDashboard = Rxn<RentDashboardModel>();
  final RxList<RentRecordModel> rentRecords = <RentRecordModel>[].obs;

  
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
    String? referenceNote,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      isSuccess.value = false;
      successMessage.value = '';

      // Create Manual/Pending Payment Record
      final paymentData = {
        'booking': bookingId,
        'amount': amount,
        'payment_gateway': gateway,
        'transaction_token': referenceNote ?? '',
      };
      
      final payment = await _service.createPayment(paymentData);
      
      if (gateway == 'manual') {
        isSuccess.value = true;
        successMessage.value = 'Payment logged successfully. Landlord has been notified.';
        loadMyPayments(showLoading: false);
      } else {
        // If they attempt automatic gateway, notify it is handled as a manual log for now
        isSuccess.value = true;
        successMessage.value = 'Logged payment via $gateway. Pending verification.';
        loadMyPayments(showLoading: false);
      }
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

  Future<void> logRentPayment({
    required int recordId,
    required String amount,
    required String referenceNote,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      isSuccess.value = false;
      successMessage.value = '';

      final updateData = {
        'status': 'pending',
        'remarks': referenceNote,
        'amount_paid': amount,
      };

      await _service.patchRentRecord(recordId, updateData);

      isSuccess.value = true;
      successMessage.value = 'Payment logged successfully. Landlord has been notified.';
    } catch (e) {
      String err = 'Failed to log payment. Please try again.';
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
      debugPrint('Error logging rent payment: $e');
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

  Future<void> verifyTenantPayment(int paymentId) async {
    try {
      isLoading.value = true;
      await _service.verifyPayment(paymentId);
      Get.snackbar(
        'Success',
        'Payment verified successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      // Reload history and dashboard data
      await loadPaymentHistory(showLoading: false);
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      Get.snackbar(
        'Error',
        'Failed to verify payment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRentDashboard({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';
      final data = await _service.getRentDashboard();
      rentDashboard.value = data;
    } catch (e) {
      errorMessage.value = 'Failed to load rent dashboard.';
      debugPrint('Error loading rent dashboard: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> loadRentRecords({bool showLoading = true, Map<String, dynamic>? params}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';
      final data = await _service.getRentRecords(params: params);
      rentRecords.assignAll(data);
    } catch (e) {
      errorMessage.value = 'Failed to load rent records.';
      debugPrint('Error loading rent records: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> updateRentRecordStatus(int recordId, String status) async {
    try {
      isLoading.value = true;
      await _service.updateRentRecordStatus(recordId, status);
      Get.snackbar(
        'Success',
        'Rent status updated to $status.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error updating rent status: $e');
      Get.snackbar(
        'Error',
        'Failed to update rent status.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
