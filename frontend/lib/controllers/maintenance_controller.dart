import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/maintenace/maintenance_model.dart';
import '../services/maintenance_service.dart';
import 'auth_controller.dart';
import '../models/room/room_model.dart';
import '../services/room_service.dart';

class MaintenanceController extends GetxController {
  final MaintenanceService _maintenanceService = MaintenanceService();
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

  final List<String> categories = ['Plumbing', 'Electrical', 'HVAC', 'Appliance', 'Other'];

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
      final res = await _roomService.getRooms(); 
      // Using getRooms for simplicity, although tenants might only want rooms they booked.
      // If there's a specific endpoint for tenant rooms, we'd use it. But for now getRooms works to populate the dropdown.
      myRooms.assignAll(res.results);
      if (myRooms.isNotEmpty) {
        selectedRoom.value = myRooms.first;
      }
    } catch (e) {
      debugPrint("Error fetching rooms: $e");
    }
  }

  Future<void> fetchMaintenanceRequests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final authController = Get.find<AuthController>();
      final role = authController.selectedRole.value.toLowerCase();
      
      List<MaintenanceModel> requests = [];
      if (role == 'landlord' || role == 'admin') {
        final res = await _maintenanceService.getAllMaintenance();
        // The API returns MaintenanceListModel which has results of type Result.
        // We need to map Result to MaintenanceModel.
        requests = res.results.map((r) => MaintenanceModel(
          id: r.id,
          tenantId: r.tenantId,
          tenantUsername: r.tenantUsername,
          room: r.room,
          description: r.description,
          status: r.status,
          image: r.image,
          createdAt: r.createdAt
        )).toList();
      } else {
        final res = await _maintenanceService.getMyMaintenanceRequests();
        requests = res.results.map((r) => MaintenanceModel(
          id: r.id,
          tenantId: r.tenantId,
          tenantUsername: r.tenantUsername,
          room: r.room,
          description: r.description,
          status: r.status,
          image: r.image,
          createdAt: r.createdAt
        )).toList();
      }
      
      maintenanceList.assignAll(requests);
    } catch (e) {
      errorMessage.value = 'Failed to load maintenance requests: ${e.toString()}';
      debugPrint('Error loading maintenance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      imagePath.value = image.path;
    }
  }

  Future<void> submitRequest() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty || selectedRoom.value == null) {
      Get.snackbar('Error', 'Please fill all fields and select a room.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      
      final fullDescription = "Category: ${selectedCategory.value}\nTitle: ${titleController.text}\n\n${descriptionController.text}";
      
      await _maintenanceService.createMaintenance(
        room: selectedRoom.value!.id ?? 0,
        description: fullDescription,
        imagePath: imagePath.value.isNotEmpty ? imagePath.value : null,
      );
      
      Get.snackbar('Success', 'Maintenance request submitted.', backgroundColor: Colors.green, colorText: Colors.white);
      
      // Clear form
      titleController.clear();
      descriptionController.clear();
      imagePath.value = '';
      selectedCategory.value = categories.first;
      
      await fetchMaintenanceRequests();
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit request: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint('Submit maintenance error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(int id, String newStatus) async {
    try {
      isLoading.value = true;
      await _maintenanceService.updateMaintenanceStatus(id, newStatus);
      Get.snackbar('Success', 'Status updated to $newStatus', backgroundColor: Colors.green, colorText: Colors.white);
      await fetchMaintenanceRequests();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint('Update maintenance status error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
