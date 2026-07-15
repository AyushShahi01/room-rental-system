import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/booking/booking_model.dart';
import '../models/booking/bookinglist_model.dart';
import '../models/room/room_detail_model.dart' as room_detail;
import '../services/booking_service.dart';
import '../services/room_service.dart';
import '../services/auth_service.dart';
import '../services/payement_service.dart';
import '../services/agreement_service.dart';
import 'room_controller.dart';
import 'tenant_dashboard_controller.dart';
import 'notification_controller.dart';

class BookingController extends GetxController {
  final BookingService _service = BookingService();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxList<Result> tenantBookings = <Result>[].obs;
  final RxList<Result> incomingBookings = <Result>[].obs;
  final Rxn<BookingModel> selectedBooking = Rxn<BookingModel>();
  final Rxn<room_detail.RoomDetailModel> selectedBookingRoom = Rxn<room_detail.RoomDetailModel>();
  final RxString tenantName = ''.obs;
  final RxString landlordName = ''.obs;
  final RxString paymentStatus = 'pending'.obs;

  // ── Agreement state ──────────────────────────────────────────────────────
  // agreementExists: true  → backend confirmed an agreement exists (HTTP 200)
  // agreementExists: false → no agreement yet (HTTP 404 or empty results)
  final RxBool agreementExists = false.obs;

  // Keep agreementStatus for display in the info row ("NOT GENERATED" / "GENERATED" / "SIGNED")
  final RxString agreementStatus = 'not generated'.obs;

  final TextEditingController roomIdController = TextEditingController();

  // ── Tenant Bookings ───────────────────────────────────────────────────────

  Future<void> loadTenantBookings({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';
      final data = await _service.getMyBookings();
      tenantBookings.assignAll(data.results);
    } catch (e) {
      errorMessage.value = 'Unable to load your bookings right now.';
      debugPrint('Error loading tenant bookings: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  // ── Incoming Bookings (landlord) ──────────────────────────────────────────

  Future<void> loadIncomingBookings({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      errorMessage.value = '';
      final data = await _service.getIncomingBookings();
      incomingBookings.assignAll(data.results);
    } catch (e) {
      errorMessage.value = 'Unable to load incoming bookings right now.';
      debugPrint('Error loading incoming bookings: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  // ── Booking Details ───────────────────────────────────────────────────────

  Future<void> loadBookingDetails(int bookingId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedBooking.value = null;
      selectedBookingRoom.value = null;
      tenantName.value = '';
      landlordName.value = '';
      paymentStatus.value = 'pending';
      // Reset agreement state before every fresh load — never use stale cache.
      agreementExists.value = false;
      agreementStatus.value = 'not generated';

      debugPrint('[BookingController] Loading booking details for ID: $bookingId');

      final booking = await _service.getBooking(bookingId);
      selectedBooking.value = booking;
      debugPrint('[BookingController] Booking ID from API: ${booking.id}');

      // 1. Fetch Room Detail
      if (booking.roomId != null) {
        try {
          final roomService = RoomService();
          selectedBookingRoom.value = await roomService.getRoom(booking.roomId!);
        } catch (e) {
          debugPrint('[BookingController] Error loading room: $e');
        }
      }

      // 2. Resolve tenant / landlord names
      if (booking.tenantName != null) {
        tenantName.value = booking.tenantName!;
      } else if (booking.tenantId != null) {
        try {
          final authService = AuthService();
          final usersData = await authService.getLandlordUsers();
          if (usersData['results'] != null) {
            final List users = usersData['results'];
            final t = users.firstWhere(
              (u) => u['id'] == booking.tenantId,
              orElse: () => null,
            );
            if (t != null) {
              tenantName.value =
                  t['username'] ?? t['first_name'] ?? booking.tenantId!;
            } else {
              tenantName.value = booking.tenantId!;
            }
          }
        } catch (_) {}
      }

      if (booking.landlordName != null) {
        landlordName.value = booking.landlordName!;
      } else {
        final landlord = selectedBookingRoom.value?.landlord;
        if (landlord != null) {
          landlordName.value = landlord.username ??
              ((landlord.firstName?.isNotEmpty == true)
                  ? '${landlord.firstName} ${landlord.lastName ?? ''}'.trim()
                  : null) ??
              landlord.id ??
              'Landlord';
        }
      }

      // 3. Fetch Payment Status
      try {
        final paymentService = PaymentService();
        final payments = await paymentService.getPaymentsByBooking(bookingId);
        if (payments.results.isNotEmpty) {
          final paidPayment = payments.results.firstWhere(
            (p) =>
                p.status?.toLowerCase() == 'paid' ||
                p.status?.toLowerCase() == 'completed',
            orElse: () => payments.results.last,
          );
          paymentStatus.value = paidPayment.status?.toLowerCase() ?? 'pending';
        }
      } catch (e) {
        debugPrint('[BookingController] Error loading payments: $e');
      }

      // 4. Fetch Agreement Status — ALWAYS hit the API, never assume.
      await refreshAgreementStatus(bookingId);

    } catch (e) {
      errorMessage.value = 'Unable to load booking details right now.';
      debugPrint('[BookingController] Error loading booking details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Hits GET /agreements/booking/{bookingId}/ and updates [agreementExists] +
  /// [agreementStatus]. HTTP 200 with parsed agreement → exists. HTTP 404 → not found.
  Future<void> refreshAgreementStatus(int bookingId) async {
    debugPrint('[BookingController] Booking ID: $bookingId');
    try {
      final agreementService = AgreementService();
      final agreement = await agreementService.getAgreementByBooking(bookingId);

      if (agreement != null && agreement.id != null) {
        agreementExists.value = true;
        agreementStatus.value =
            agreement.isSigned == true ? 'signed' : 'generated';
        debugPrint(
          '[BookingController] agreementExists=true, Agreement ID: ${agreement.id}, status: ${agreementStatus.value}',
        );
      } else {
        agreementExists.value = false;
        agreementStatus.value = 'not generated';
        debugPrint('[BookingController] agreementExists=false (empty response)');
      }
    } on DioException catch (e) {
      debugPrint('[BookingController] HTTP Status: ${e.response?.statusCode}');
      if (e.response?.statusCode == 404) {
        agreementExists.value = false;
        agreementStatus.value = 'not generated';
        debugPrint('[BookingController] agreementExists=false (404)');
      } else {
        debugPrint('[BookingController] Agreement API error: $e');
      }
    } catch (e) {
      debugPrint('[BookingController] Unexpected error fetching agreement: $e');
    }
  }

  // ── Booking Actions ───────────────────────────────────────────────────────

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
      if (Get.isRegistered<RoomController>()) {
        Get.find<RoomController>().loadRooms(refresh: true);
      }
      if (Get.isRegistered<TenantDashboardController>()) {
        Get.find<TenantDashboardController>().loadDashboardData();
      }
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().refreshState();
      }
      successMessage.value = 'Booking request submitted successfully.';
    } catch (e) {
      errorMessage.value = 'Unable to create a booking request right now.';
      debugPrint('[BookingController] Error creating booking: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> approveBooking(int bookingId, String startDate) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      await _service.approveBooking(bookingId, startDate);
      await loadIncomingBookings(showLoading: false);
      await loadBookingDetails(bookingId);
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().refreshState();
      }
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
      debugPrint('[BookingController] Error approving booking: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> showApproveDialog(BuildContext context, int bookingId, {VoidCallback? onSuccess}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Starting Rent Date',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: Colors.blueAccent.shade700),
              const SizedBox(width: 10),
              const Text('Confirm Start Date'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rent will be tracked on a monthly calendar basis starting from:',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text('CANCEL', style: TextStyle(color: Colors.grey.shade600)),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await approveBooking(bookingId, formattedDate);
                if (onSuccess != null) {
                  onSuccess();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );
  }

  Future<void> rejectBooking(int bookingId) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      await _service.rejectBooking(bookingId);
      await loadIncomingBookings(showLoading: false);
      await loadBookingDetails(bookingId);
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().refreshState();
      }
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
      debugPrint('[BookingController] Error rejecting booking: $e');
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
      if (Get.isRegistered<RoomController>()) {
        Get.find<RoomController>().loadRooms(refresh: true);
      }
      if (Get.isRegistered<TenantDashboardController>()) {
        Get.find<TenantDashboardController>().loadDashboardData();
      }
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().refreshState();
      }
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
      debugPrint('[BookingController] Error cancelling booking: $e');
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
