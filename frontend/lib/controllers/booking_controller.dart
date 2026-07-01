import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/booking/booking_model.dart';
import '../models/booking/bookinglist_model.dart';
import '../services/booking_service.dart';

class BookingController extends GetxController {
  final BookingService _service = BookingService();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxList<Result> tenantBookings = <Result>[].obs;
  final RxList<Result> incomingBookings = <Result>[].obs;
  final Rxn<BookingModel> selectedBooking = Rxn<BookingModel>();
  final TextEditingController roomIdController = TextEditingController();

  Future<void> loadTenantBookings({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = '';
      final data = await _service.getMyBookings();
      tenantBookings.assignAll(data.results);
    } catch (e) {
      errorMessage.value = 'Unable to load your bookings right now.';
      debugPrint('Error loading tenant bookings: $e');
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadIncomingBookings({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading.value = true;
      }
      errorMessage.value = '';
      final data = await _service.getIncomingBookings();
      incomingBookings.assignAll(data.results);
    } catch (e) {
      errorMessage.value = 'Unable to load incoming bookings right now.';
      debugPrint('Error loading incoming bookings: $e');
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadBookingDetails(int bookingId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final booking = await _service.getBooking(bookingId);
      selectedBooking.value = booking;
    } catch (e) {
      errorMessage.value = 'Unable to load booking details right now.';
      debugPrint('Error loading booking details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBooking() async {
    final roomId = int.tryParse(roomIdController.text.trim());
    if (roomId == null || roomId <= 0) {
      errorMessage.value = 'Please enter a valid room ID.';
      return;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      final booking = await _service.createBooking({'room': roomId});
      selectedBooking.value = booking;
      roomIdController.clear();
      await loadTenantBookings(showLoading: false);
      successMessage.value = 'Booking request submitted successfully.';
      Get.snackbar(
        'Booking created',
        'Your request is now pending review.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Unable to create a booking request right now.';
      debugPrint('Error creating booking: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> approveBooking(int bookingId) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      await _service.approveBooking(bookingId);
      await loadIncomingBookings(showLoading: false);
      await loadBookingDetails(bookingId);
      successMessage.value = 'Booking approved.';
      Get.snackbar(
        'Approved',
        'Booking was approved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Unable to approve this booking.';
      debugPrint('Error approving booking: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> rejectBooking(int bookingId) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      await _service.rejectBooking(bookingId);
      await loadIncomingBookings(showLoading: false);
      await loadBookingDetails(bookingId);
      successMessage.value = 'Booking rejected.';
      Get.snackbar(
        'Rejected',
        'Booking was rejected.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Unable to reject this booking.';
      debugPrint('Error rejecting booking: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      await _service.cancelBooking(bookingId);
      await loadTenantBookings(showLoading: false);
      await loadIncomingBookings(showLoading: false);
      await loadBookingDetails(bookingId);
      successMessage.value = 'Booking cancelled.';
      Get.snackbar(
        'Cancelled',
        'Booking was cancelled.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey.shade700,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Unable to cancel this booking.';
      debugPrint('Error cancelling booking: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    roomIdController.dispose();
    super.onClose();
  }
}
