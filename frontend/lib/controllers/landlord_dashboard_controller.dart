import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/auth_model/landlord_dash_model.dart';

class LandlordDashboardController extends GetxController {
  final AuthService _authService = AuthService();

  final RxInt selectedIndex = 0.obs;

  final Rxn<LandlordDashModel> dashboardData = Rxn<LandlordDashModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Landlord / Admin statistics from GET /api/auth/admin/dashboard/
  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;
  final RxList<dynamic> users = <dynamic>[].obs;

  // Booking summary placeholders (wired to real API later)
  final RxInt totalRooms = 0.obs;
  final RxInt pendingBookings = 0.obs;
  final RxInt totalPayments = 0.obs;
  final RxInt maintenanceRequests = 0.obs;
  final RxList<dynamic> recentActivities = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // GET /api/auth/admin/dashboard/ → {total_users, active_users, staff_users}
      final dashData = await _authService.getAdminStats();
      stats.assignAll(dashData);
      dashboardData.value = LandlordDashModel(
        message:
            'Welcome! Total users: ${dashData['total_users'] ?? 0}, '
            'Active: ${dashData['active_users'] ?? 0}.',
      );

      // GET /api/auth/admin/users/ → {count, results: [...]}
      final usersData = await _authService.getLandlordUsers();
      if (usersData['results'] != null) {
        users.assignAll(usersData['results'] as List);
      } else {
        users.clear();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard: ${e.toString()}';
      debugPrint('Error loading landlord dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// PATCH /api/auth/admin/users/{id}/ban/
  Future<void> banUser(String userId) async {
    try {
      isLoading.value = true;
      final res = await _authService.banUser(userId);
      Get.snackbar(
        'User Banned',
        res['message'] ?? 'User has been banned.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      await loadDashboardData();
    } catch (e) {
      Get.snackbar(
        'Action Failed',
        'Unable to ban user. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveBooking(int bookingId) async {
    Get.snackbar(
      'Success',
      'Booking #$bookingId approved successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> rejectBooking(int bookingId) async {
    Get.snackbar(
      'Rejected',
      'Booking #$bookingId rejected.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
