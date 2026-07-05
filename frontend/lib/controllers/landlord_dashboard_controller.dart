import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/auth_model/landlord_dash_model.dart';
import '../services/room_service.dart';
import '../services/booking_service.dart';
import '../services/maintenance_service.dart';
import 'payement_controller.dart';
import 'booking_controller.dart';

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
  final RxDouble totalRentCollected = 0.0.obs;
  final RxDouble totalPendingRent = 0.0.obs;
  final RxInt overdueTenantsCount = 0.obs;
  final RxList<ActivityItem> recentActivities = <ActivityItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().errorMessage.value = '';
    }
  }

  Future<void> loadDashboardData() async {
    List<ActivityItem> activities = [];
    List<dynamic> localUsers = [];
    List<dynamic> localRooms = [];
    try {
      isLoading.value = true;
      errorMessage.value = '';

      try {
        // GET /api/auth/admin/dashboard/ → {total_users, active_users, staff_users}
        final dashData = await _authService.getAdminStats();
        stats.assignAll(dashData);
        dashboardData.value = LandlordDashModel(
          message:
              'Welcome! Total users: ${dashData['total_users'] ?? 0}, '
              'Active: ${dashData['active_users'] ?? 0}.',
        );
        try {
          // GET /api/auth/admin/users/ → {count, results: [...]}
          final usersData = await _authService.getLandlordUsers();
          if (usersData['results'] != null) {
            localUsers = usersData['results'] as List;
            users.assignAll(localUsers);
          } else {
            users.clear();
          }
        } catch (e) {
          debugPrint('Failed to load admin stats: $e');
        }
      } catch (e) {
        debugPrint('Failed to load admin stats: $e');
        // We do not throw here to allow fetching rooms & bookings below
      }

      try {
        final roomService = RoomService();
        final roomsRes = await roomService.getMyRooms();
        localRooms = roomsRes.results;
        totalRooms.value = localRooms.length;

        for (var room in localRooms) {
          activities.add(ActivityItem(
            title: 'Room Posted: ${room.title ?? 'Unknown'}',
            subtitle: 'Price: ₹${room.price ?? '0'}',
            date: room.createdAt ?? DateTime.now().subtract(const Duration(days: 30)),
            type: 'room',
            data: room,
          ));
        }
      } catch (e) {
        debugPrint('Failed to load rooms count: $e');
      }

      try {
        final bookingService = BookingService();
        final bookingsRes = await bookingService.getIncomingBookings();
        pendingBookings.value = bookingsRes.results.where((b) => b.status == 'pending').length;

        for (var b in bookingsRes.results) {
          // b.tenant is a UUID string after the resilient parsing fix
          String tenantName = 'Unknown Tenant';
          if (b.tenant != null) {
            dynamic userObj;
            try {
              userObj = localUsers.firstWhere((u) => u['id'] == b.tenant);
            } catch (_) {}
            if (userObj != null) {
              final String firstName = userObj['first_name'] ?? '';
              final String lastName = userObj['last_name'] ?? '';
              final String fullName = '$firstName $lastName'.trim();
              tenantName = fullName.isNotEmpty ? fullName : (userObj['username'] ?? b.tenant!);
            } else {
              tenantName = b.tenantName ?? b.tenant!;
            }
          }

          String roomName = b.room != null ? 'Room #${b.room}' : 'Unknown Room';
          try {
            final roomObj = localRooms.firstWhere((r) => r.id == b.room);
            roomName = roomObj.title ?? roomName;
          } catch (_) {}

          activities.add(ActivityItem(
            title: 'Booking Request',
            subtitle: '$tenantName requested $roomName',
            date: DateTime.now(), // Bookings API lacks date right now
            type: 'booking',
            data: b,
          ));
        }
      } catch (e) {
        debugPrint('Failed to load bookings count: $e');
      }

      try {
        final maintenanceService = MaintenanceService();
        final maintenanceRes = await maintenanceService.getAllMaintenance();
        maintenanceRequests.value = maintenanceRes.results.where((m) => m.status == 'pending').length;

        for (var m in maintenanceRes.results) {
          activities.add(ActivityItem(
            title: 'Maintenance: ${m.status?.toUpperCase() ?? 'PENDING'}',
            subtitle: 'Room ${m.room ?? ''} — ${m.tenantDisplay} — ${m.description ?? ''}',
            date: m.createdAt ?? DateTime.now(),
            type: 'maintenance',
            data: m,
          ));
        }
      } catch (e) {
        debugPrint('Failed to load maintenance count: $e');
      }

      try {
        final paymentController = Get.isRegistered<PaymentController>()
            ? Get.find<PaymentController>()
            : Get.put(PaymentController());
        await paymentController.loadRentDashboard(showLoading: false);
        final dash = paymentController.rentDashboard.value;
        if (dash != null) {
          totalRentCollected.value = dash.totalRentCollected;
          totalPendingRent.value = dash.totalPendingRent;
          overdueTenantsCount.value = dash.overdueTenants.length;
          totalPayments.value = dash.overdueTenants.length;
          for (var record in dash.overdueTenants) {
            activities.add(ActivityItem(
              title: 'Overdue Rent: ${record.tenant.displayName}',
              subtitle: '${record.room.title} — ₹${record.amount} is unpaid',
              date: record.createdAt,
              type: 'rent',
              data: record,
            ));
          }
        }
      } catch (e) {
        debugPrint('Failed to load rent dashboard stats: $e');
      }

    } catch (e) {
      errorMessage.value = 'Failed to load dashboard: ${e.toString()}';
      debugPrint('Error loading landlord dashboard: $e');
    } finally {
      activities.sort((a, b) => b.date.compareTo(a.date));
      recentActivities.assignAll(activities.take(15).toList());
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


}

class ActivityItem {
  final String title;
  final String subtitle;
  final DateTime date;
  final String type; 
  final dynamic data;

  ActivityItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.type,
    this.data,
  });
}
