import 'dart:io';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../models/room/recommendation_model.dart' as rec_model;
import '../models/room/room_detail_model.dart' as room_detail;
import '../models/room/room_model.dart' as room_model;
import '../services/room_service.dart';
import '../services/booking_service.dart';
import '../models/booking/bookinglist_model.dart';
import 'package:flutter/material.dart';

class RoomController extends GetxController {
  final RoomService _roomService = RoomService();

  // Tenant Explore
  var isRoomsLoading = true.obs;
  var rooms = <room_model.Result>[].obs;
  var recommendedRooms = <rec_model.Result>[].obs;

  // Landlord Rooms
  var isMyRoomsLoading = true.obs;
  var myRooms = <room_model.Result>[].obs;

  // Room Details
  var isRoomDetailLoading = true.obs;
  var currentRoomDetail = Rxn<room_detail.RoomDetailModel>();



  // Pagination State
  var page = 1;
  var hasNextPage = true.obs;
  var isLoadMoreLoading = false.obs;

  Future<void> loadRooms({bool refresh = true}) async {
    if (refresh) {
      page = 1;
      hasNextPage.value = true;
      isRoomsLoading.value = true;
    }
    try {
      final bookingService = BookingService();
      var bookedRoomIds = <int>{};
      try {
        final BookingListModel bookingsRes = await bookingService.getMyBookings();
        bookedRoomIds = bookingsRes.results
            .where((b) => b.status?.toLowerCase() != 'cancelled' && b.status?.toLowerCase() != 'rejected')
            .map((b) => b.roomId)
            .whereType<int>()
            .toSet();
      } catch (e) {
        debugPrint('Error fetching tenant bookings in RoomController: $e');
      }

      final response = await _roomService.getRooms(filters: {'page': page});
      final fetchedRooms = response.results
          .where((r) => r.isAvailable == true && !bookedRoomIds.contains(r.id))
          .toList();

      if (refresh) {
        rooms.value = fetchedRooms;
        final recommendations = await _roomService.getRecommendations({});
        recommendedRooms.value = recommendations.results
            .where((r) => r.room?.isAvailable == true && !bookedRoomIds.contains(r.room?.id))
            .toList();
      } else {
        // Append unique rooms
        for (var r in fetchedRooms) {
          if (!rooms.contains(r)) {
            rooms.add(r);
          }
        }
      }
      
      hasNextPage.value = response.next != null;
      if (hasNextPage.value) {
        page++;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load rooms: $e');
    } finally {
      if (refresh) {
        isRoomsLoading.value = false;
      }
    }
  }

  Future<void> loadMoreRooms() async {
    if (isLoadMoreLoading.value || !hasNextPage.value) return;
    isLoadMoreLoading.value = true;
    try {
      await loadRooms(refresh: false);
    } finally {
      isLoadMoreLoading.value = false;
    }
  }

  Future<void> loadMyRooms() async {
    isMyRoomsLoading.value = true;
    try {
      final response = await _roomService.getMyRooms();
      myRooms.value = response.results;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load rooms: $e');
    } finally {
      isMyRoomsLoading.value = false;
    }
  }

  Future<void> loadRoomDetail(int id) async {
    isRoomDetailLoading.value = true;
    currentRoomDetail.value = null;
    try {
      final room = await _roomService.getRoom(id);
      currentRoomDetail.value = room;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load room: $e');
    } finally {
      isRoomDetailLoading.value = false;
    }
  }



  Future<room_detail.RoomDetailModel?> createRoom(Map<String, dynamic> data) async {
    try {
      final userId = Get.find<AuthController>().currentUser.value?.id;
      if (userId != null) {
        data['landlord'] = userId;
      }
      final result = await _roomService.createRoom(data);
      Get.snackbar('Success', 'Room added successfully');
      loadMyRooms();
      return result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create room: $e');
      rethrow;
    }
  }

  Future<void> updateRoom(int id, Map<String, dynamic> data) async {
    try {
      await _roomService.patchRoom(id, data);
      Get.snackbar('Success', 'Room updated successfully');
      loadMyRooms();
      if (currentRoomDetail.value?.id == id) {
        loadRoomDetail(id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update room: $e');
      rethrow;
    }
  }

  Future<void> deleteRoom(int id) async {
    try {
      await _roomService.deleteRoom(id);
      Get.snackbar('Success', 'Room deleted successfully');
      loadMyRooms();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete room: $e');
    }
  }

  Future<void> toggleAvailability(int id) async {
    try {
      await _roomService.toggleAvailability(id);
      Get.snackbar('Success', 'Availability updated');
      loadMyRooms();
      if (currentRoomDetail.value?.id == id) {
        loadRoomDetail(id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle availability: $e');
    }
  }

  Future<void> uploadRoomImage(int id, File imageFile) async {
    try {
      await _roomService.uploadRoomImage(id, imageFile);
      Get.snackbar('Success', 'Image uploaded successfully');
      // Automatically refresh details and lists so image appears immediately
      if (currentRoomDetail.value?.id == id) {
        loadRoomDetail(id);
      } else {
        loadRoomDetail(id);
      }
      loadRooms();
      loadMyRooms();
    } catch (e) {
      Get.snackbar('Error', 'Upload failed: $e');
      rethrow;
    }
  }
}
