import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/room/room_model.dart';
import '../models/booking/booking_model.dart';
import '../models/booking/bookinglist_model.dart';
import '../services/room_service.dart';
import '../services/booking_service.dart';
import 'booking_controller.dart';

class TenantDashboardController extends GetxController {
  final RoomService _roomService = RoomService();
  final BookingService _bookingService = BookingService();

  final RxInt selectedIndex = 0.obs;

  final Rxn<RoomModel> dashboardData = Rxn<RoomModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Active stay / filters state
  final Rxn<BookingModel> activeBooking = Rxn<BookingModel>();
  final RxString selectedFilterTag = ''.obs;

  final List<String> filterTags = [
    'Wi-Fi',
    'AC',
    'Furnished',
    'Parking',
    'Bath',
  ];

  // Search parameters needed by tenant views
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isSearchMode = false.obs;
  final RxList<dynamic> searchResults = <dynamic>[].obs;
  final RxBool isSearching = false.obs;

  // Property list parameters needed by tenant views
  final RxList<dynamic> allProperties = <dynamic>[].obs;
  final RxList<dynamic> featuredProperties = <dynamic>[].obs;
  final RxList<dynamic> nearbyProperties = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().errorMessage.value = '';
    }
  }

  void toggleFilterTag(String tag) {
    if (selectedFilterTag.value == tag) {
      selectedFilterTag.value = '';
    } else {
      selectedFilterTag.value = tag;
    }
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _roomService.getRooms();
      dashboardData.value = data;

      // Fetch bookings to filter out requested/approved rooms
      var bookedRoomIds = <int>{};
      BookingListModel? tenantBookingsRes;
      try {
        tenantBookingsRes = await _bookingService.getMyBookings();
        bookedRoomIds = tenantBookingsRes.results
            .where((b) => b.status?.toLowerCase() != 'cancelled' && b.status?.toLowerCase() != 'rejected')
            .map((b) => b.roomId)
            .whereType<int>()
            .toSet();
      } catch (e) {
        debugPrint('Error fetching tenant bookings in loadDashboardData: $e');
      }

      final filteredResults = data.results
          .where((r) => r.isAvailable == true && !bookedRoomIds.contains(r.id))
          .toList();
      allProperties.assignAll(filteredResults);
      featuredProperties.assignAll(filteredResults.take(3).toList());

      // Fetch active stay
      try {
        final BookingListModel bookingsRes = tenantBookingsRes ?? await _bookingService.getMyBookings();
        final approved = bookingsRes.results.firstWhereOrNull(
          (b) => b.status?.toLowerCase() == 'approved',
        );
        if (approved != null) {
          final fullBooking = await _bookingService.getBooking(approved.id!);
          activeBooking.value = fullBooking;
        } else {
          activeBooking.value = null;
        }
      } catch (e) {
        debugPrint('Error loading active stay booking: $e');
        activeBooking.value = null;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load rooms: ${e.toString()}';
      debugPrint('Error loading tenant dashboard rooms: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performSearch(String query) async {
    searchQuery.value = query.trim();
    if (searchQuery.value.isEmpty) {
      isSearchMode.value = false;
      searchResults.clear();
    } else {
      isSearchMode.value = true;
      isSearching.value = true;
      try {
        final data = await _roomService.getRooms(filters: {'search': searchQuery.value});
        searchResults.assignAll(data.results.where((r) => r.isAvailable == true).toList());
      } catch (e) {
        debugPrint('Error searching rooms: $e');
      } finally {
        isSearching.value = false;
      }
    }
  }
}
