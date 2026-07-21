import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/room/room_model.dart';
import '../models/booking/booking_model.dart';
import '../models/booking/bookinglist_model.dart';
import '../services/room_service.dart';
import '../services/booking_service.dart';
import 'booking_controller.dart';
import 'notification_controller.dart';

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
  final RxList<dynamic> recommendedRooms = <dynamic>[].obs;

  // Advanced Filter State
  final RxDouble maxPrice = 100000.0.obs;
  final RxBool filterWifi = false.obs;
  final RxBool filterAc = false.obs;
  final RxBool filterFurnished = false.obs;
  final RxBool filterParking = false.obs;
  final RxBool filterBath = false.obs;
  final RxString filterGender = 'any'.obs;

  void resetFilters() {
    maxPrice.value = 100000.0;
    filterWifi.value = false;
    filterAc.value = false;
    filterFurnished.value = false;
    filterParking.value = false;
    filterBath.value = false;
    filterGender.value = 'any';
    selectedFilterTag.value = '';
  }


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

  // Pagination State
  var page = 1;
  final RxBool hasNextPage = true.obs;
  final RxBool isLoadMoreLoading = false.obs;

  Future<void> loadDashboardData({bool refresh = true}) async {
    try {
      if (refresh) {
        page = 1;
        hasNextPage.value = true;
        isLoading.value = true;
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().fetchNotifications();
        }
      }
      errorMessage.value = '';
      
      final data = await _roomService.getRooms(filters: {'page': page, 'ordering': '-created_at'});
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
          
      if (refresh) {
        allProperties.assignAll(filteredResults);
      } else {
        allProperties.addAll(filteredResults.where((r) => !allProperties.contains(r)));
      }
      
      // Implement sorting: latest-first order (Recent Rooms)
      allProperties.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      if (refresh) {
        featuredProperties.assignAll(allProperties.take(3).toList());
        
        // Fetch recommendations from API
        try {
          final recs = await _roomService.getRecommendedRoomResults({});
          final filteredRecs = recs
              .where((r) => r.isAvailable == true && !bookedRoomIds.contains(r.id))
              .toList();
          recommendedRooms.assignAll(filteredRecs);
        } catch (e) {
          debugPrint('Error fetching recommendations in loadDashboardData: $e');
          // Fallback to top available rooms
          recommendedRooms.assignAll(allProperties.take(5).toList());
        }
      }
      
      hasNextPage.value = data.next != null;
      if (hasNextPage.value) {
        page++;
      }

      // Fetch active stay
      if (refresh) {
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
      }
    } catch (e) {
      errorMessage.value = 'Failed to load rooms: ${e.toString()}';
      debugPrint('Error loading tenant dashboard rooms: $e');
    } finally {
      if (refresh) isLoading.value = false;
      isLoadMoreLoading.value = false;
    }
  }

  Future<void> loadMoreRooms() async {
    if (isLoadMoreLoading.value || !hasNextPage.value) return;
    isLoadMoreLoading.value = true;
    try {
      await loadDashboardData(refresh: false);
    } finally {
      isLoadMoreLoading.value = false;
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
        final data = await _roomService.getRooms(filters: {'search': searchQuery.value, 'ordering': '-created_at'});
        final filteredSearch = data.results.where((r) => r.isAvailable == true).toList();
        filteredSearch.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
        searchResults.assignAll(filteredSearch);
      } catch (e) {
        debugPrint('Error searching rooms: $e');
      } finally {
        isSearching.value = false;
      }
    }
  }
}
