import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/agreement/agreement_model.dart';
import '../services/agreement_service.dart';
import 'booking_controller.dart';

class AgreementController extends GetxController {
  final AgreementService _service = AgreementService();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  final Rx<AgreementModel?> agreement = Rx<AgreementModel?>(null);

  Future<void> loadAgreementByBooking(int bookingId) async {
    debugPrint('[AgreementController] Booking ID: $bookingId');
    try {
      isLoading.value = true;
      errorMessage.value = '';
      agreement.value = null;

      final summary = await _service.getAgreementByBooking(bookingId);
      final exists = summary?.id != null;
      debugPrint('[AgreementController] agreementExists=$exists');

      if (summary?.id != null) {
        agreement.value = await _service.getAgreement(summary!.id!);
        debugPrint(
          '[AgreementController] Agreement ID: ${agreement.value?.id}, Parsed: ${agreement.value}',
        );
      }
    } on DioException catch (e) {
      debugPrint('[AgreementController] HTTP Status: ${e.response?.statusCode}');
      if (e.response?.statusCode == 404) {
        agreement.value = null;
        errorMessage.value = '';
        debugPrint('[AgreementController] agreementExists=false (404)');
      } else {
        String err = 'Failed to load agreement.';
        if (e.response?.data != null) {
          if (e.response!.data is Map) {
            err = (e.response!.data as Map).values.join(', ');
          } else {
            err = e.response!.data.toString();
          }
        }
        errorMessage.value = err;
        debugPrint('[AgreementController] Error loading agreement: $e');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load agreement.';
      debugPrint('[AgreementController] Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshBookingState(int bookingId) async {
    if (Get.isRegistered<BookingController>()) {
      final bookingController = Get.find<BookingController>();
      await bookingController.loadBookingDetails(bookingId);
    }
  }

  Future<void> createAgreement(int bookingId, Map<String, dynamic> payload) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      debugPrint('[AgreementController] Creating agreement for Booking ID: $bookingId');
      await _service.createAgreement({
        'booking': bookingId,
        ...payload,
      });

      successMessage.value = 'Agreement created successfully!';

      Get.snackbar(
        'Success',
        'Agreement created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );

      // Reload agreement from backend, then refresh booking UI.
      await loadAgreementByBooking(bookingId);
      await _refreshBookingState(bookingId);
    } catch (e) {
      String err = 'Failed to create agreement.';
      var alreadyExists = false;
      if (e is DioException && e.response?.data != null) {
        if (e.response!.data is Map) {
          err = (e.response!.data as Map).values.join(', ');
        } else {
          err = e.response!.data.toString();
        }
        if (err.toLowerCase().contains('already exists')) {
          alreadyExists = true;
        }
      }

      if (alreadyExists) {
        debugPrint('[AgreementController] Agreement already exists, reloading...');
        await loadAgreementByBooking(bookingId);
        await _refreshBookingState(bookingId);

        successMessage.value = 'Agreement retrieved successfully!';
        Get.snackbar(
          'Info',
          'Agreement for this booking already exists and was loaded.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.shade700,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = err;
        debugPrint('[AgreementController] Error creating agreement: $e');
        Get.snackbar(
          'Error',
          err,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> signAgreement(int bookingId) async {
    if (agreement.value?.id == null) return;

    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      debugPrint(
        '[AgreementController] Signing Agreement ID: ${agreement.value!.id} for Booking ID: $bookingId',
      );
      await _service.signAgreement(agreement.value!.id!);

      successMessage.value = 'Agreement signed successfully!';

      Get.snackbar(
        'Success',
        'Agreement signed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );

      await loadAgreementByBooking(bookingId);
      await _refreshBookingState(bookingId);
    } catch (e) {
      String err = 'Failed to sign agreement.';
      if (e is DioException && e.response?.data != null) {
        if (e.response!.data is Map) {
          err = (e.response!.data as Map).values.join(', ');
        } else {
          err = e.response!.data.toString();
        }
      }
      errorMessage.value = err;
      debugPrint('[AgreementController] Error signing agreement: $e');
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
