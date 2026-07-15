import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/maintenace/maintenance_model.dart';
import '../services/maintenance_service.dart';
import '../services/booking_service.dart';
import '../services/room_service.dart';
import 'auth_controller.dart';
import '../models/room/room_model.dart';
import 'notification_controller.dart';

class MaintenanceController extends GetxController {
  final MaintenanceService _maintenanceService = MaintenanceService();
  final BookingService _bookingService = BookingService();
  final RoomService _roomService = RoomService();

  final RxList<MaintenanceModel> maintenanceList = <MaintenanceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Tenant form fields
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedCategory = 'Plumbing'.obs;
  final Rx<Result?> selectedRoom = Rx<Result?>(null);
  final RxString imagePath = ''.obs;
  final RxList<Result> myRooms = <Result>[].obs;

  final List<String> categories = [
    'Plumbing',
    'Electrical',
    'HVAC',
    'Appliance',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchMaintenanceRequests();

    final authController = Get.find<AuthController>();
    final role = authController.selectedRole.value.toLowerCase();
    if (role == 'tenant' || role == 'user') {
      fetchMyRooms();
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchMyRooms() async {
    try {
      // Fetch only the rooms the tenant has an approved booking for.
      // This ensures a maintenance request is always routed to the correct
      // landlord (room.landlord) and never sent to an unrelated landlord.
      final bookingsRes = await _bookingService.getMyBookings();
      final approvedBookings = bookingsRes.results
          .where((b) => b.status?.toLowerCase() == 'approved')
          .toList();

      // Collect unique room IDs from approved bookings.
      final seenIds = <int>{};
      final rooms = <Result>[];
      for (final booking in approvedBookings) {
        final roomId = booking.roomId;
        if (roomId != null && seenIds.add(roomId)) {
          try {
            final roomDetail = await _roomService.getRoom(roomId);
            rooms.add(
              Result(
                id: roomDetail.id,
                images: roomDetail.images
                    .map(
                      (img) => RoomImage(
                        id: img.id,
                        room: img.room,
                        image: img.image,
                        createdAt: img.createdAt,
                      ),
                    )
                    .toList(),
                title: roomDetail.title,
                description: roomDetail.description,
                price: roomDetail.price,
                province: roomDetail.province,
                state: roomDetail.state,
                wardNumber: roomDetail.wardNumber,
                furnishedStatus: roomDetail.furnishedStatus,
                areaSqft: roomDetail.areaSqft,
                securityDeposit: roomDetail.securityDeposit,
                maintenanceCharges: roomDetail.maintenanceCharges,
                hasWifi: roomDetail.hasWifi,
                hasAc: roomDetail.hasAc,
                hasAttachedBathroom: roomDetail.hasAttachedBathroom,
                parkingAvailable: roomDetail.parkingAvailable,
                foodAvailable: roomDetail.foodAvailable,
                genderPreference: roomDetail.genderPreference,
                waterSupplyAvailable: roomDetail.waterSupplyAvailable,
                wasteCollectionAvailable: roomDetail.wasteCollectionAvailable,
                isAvailable: roomDetail.isAvailable,
                latitude: roomDetail.latitude,
                longitude: roomDetail.longitude,
                createdAt: roomDetail.createdAt,
                updatedAt: roomDetail.updatedAt,
                landlord: roomDetail.landlord,
              ),
            );
          } catch (e) {
            debugPrint('Error fetching room $roomId detail: $e. Using booking details as fallback.');
            rooms.add(
              Result(
                id: booking.roomId,
                images: booking.roomImages
                    .map(
                      (img) => RoomImage(
                        id: 0,
                        room: booking.roomId,
                        image: img,
                        createdAt: DateTime.now(),
                      ),
                    )
                    .toList(),
                title: booking.roomTitle ?? 'Room #${booking.roomId}',
                description: '',
                price: booking.roomPrice,
                province: booking.roomProvince,
                state: booking.roomState,
                wardNumber: null,
                furnishedStatus: null,
                areaSqft: null,
                securityDeposit: null,
                maintenanceCharges: null,
                hasWifi: null,
                hasAc: null,
                hasAttachedBathroom: null,
                parkingAvailable: null,
                foodAvailable: null,
                genderPreference: 'any',
                waterSupplyAvailable: null,
                wasteCollectionAvailable: null,
                isAvailable: true,
                latitude: null,
                longitude: null,
                createdAt: booking.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
                landlord: null,
              ),
            );
          }
        }
      }

      myRooms.assignAll(rooms);
      if (myRooms.isNotEmpty) {
        selectedRoom.value = myRooms.first;
      } else {
        selectedRoom.value = null;
      }
    } catch (e) {
      debugPrint('Error fetching tenant rooms: $e');
    }
  }

  Future<void> fetchMaintenanceRequests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final authController = Get.find<AuthController>();
      final role = authController.selectedRole.value.toLowerCase();

      List<MaintenanceModel> requests = [];
      if (role == 'landlord') {
        final res = await _maintenanceService.getAllMaintenance();
        final myRoomsRes = await _roomService.getMyRooms();
        final myRoomIds = myRoomsRes.results.map((r) => r.id).toSet();

        requests = res.results
            .where((r) => myRoomIds.contains(r.room))
            .map(
              (r) => MaintenanceModel(
                id: r.id,
                tenantId: r.tenantId,
                tenantUsername: r.tenantUsername,
                room: r.room,
                description: r.description,
                status: r.status,
                image: r.image,
                createdAt: r.createdAt,
              ),
            )
            .toList();
      } else if (role == 'admin') {
        final res = await _maintenanceService.getAllMaintenance();
        requests = res.results
            .map(
              (r) => MaintenanceModel(
                id: r.id,
                tenantId: r.tenantId,
                tenantUsername: r.tenantUsername,
                room: r.room,
                description: r.description,
                status: r.status,
                image: r.image,
                createdAt: r.createdAt,
              ),
            )
            .toList();
      } else {
        final res = await _maintenanceService.getMyMaintenanceRequests();
        requests = res.results
            .map(
              (r) => MaintenanceModel(
                id: r.id,
                tenantId: r.tenantId,
                tenantUsername: r.tenantUsername,
                room: r.room,
                description: r.description,
                status: r.status,
                image: r.image,
                createdAt: r.createdAt,
              ),
            )
            .toList();
      }

      maintenanceList.assignAll(requests);
    } catch (e) {
      errorMessage.value =
          'Failed to load maintenance requests: ${e.toString()}';
      debugPrint('Error loading maintenance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        imagePath.value = pickedFile.path;
      }
    } catch (e) {
      debugPrint('Error picking image for maintenance request: $e');
    }
  }

  void removeImage() {
    imagePath.value = '';
  }

  Future<void> submitRequest() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedRoom.value == null) {
      Get.snackbar(
        'Error',
        'Please fill all fields and select a room.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final fullDescription =
          "Category: ${selectedCategory.value}\nTitle: ${titleController.text}\n\n${descriptionController.text}";

      await _maintenanceService.createMaintenance(
        room: selectedRoom.value!.id ?? 0,
        description: fullDescription,
        imagePath: imagePath.value.isNotEmpty ? imagePath.value : null,
      );
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().refreshState();
      }

      Get.snackbar(
        'Success',
        'Maintenance request submitted.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear form
      titleController.clear();
      descriptionController.clear();
      imagePath.value = '';
      selectedCategory.value = categories.first;

      await fetchMaintenanceRequests();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit request: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('Submit maintenance error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(int id, String newStatus) async {
    try {
      isLoading.value = true;
      await _maintenanceService.updateMaintenanceStatus(id, newStatus);
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().refreshState();
      }
      Get.snackbar(
        'Success',
        'Status updated to $newStatus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await fetchMaintenanceRequests();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('Update maintenance status error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
