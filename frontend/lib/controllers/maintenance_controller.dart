import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/maintenance_model.dart';
import 'auth_controller.dart';
import 'dashboard_controller.dart';

class MaintenanceController extends GetxController {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  
  var selectedCategory = "Plumbing".obs;
  final categories = ["Plumbing", "Electrical", "Carpentry", "Other"];

  var maintenanceRequests = <MaintenanceModel>[].obs;

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void submitRequest() {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final authCtrl = Get.find<AuthController>();

    final newReq = MaintenanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      description: descController.text,
      category: selectedCategory.value,
      tenantName: authCtrl.userName.value,
      roomTitle: "My Room", // Placeholder dummy room
      status: "Pending",
    );

    maintenanceRequests.add(newReq);

    Get.snackbar("Success", "Maintenance request submitted!", backgroundColor: Colors.green, colorText: Colors.white);
    
    // Clear fields
    titleController.clear();
    descController.clear();
    
    // Navigate strictly back to dashboard home tab automatically
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().changeTab(0);
    }
  }

  void resolveRequest(String id) {
    final req = maintenanceRequests.firstWhereOrNull((r) => r.id == id);
    if (req != null) {
      req.status.value = "Resolved";
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    super.onClose();
  }
}
