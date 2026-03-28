import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MaintenanceController extends GetxController {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  
  var selectedCategory = "Plumbing".obs;
  final categories = ["Plumbing", "Electrical", "Carpentry", "Other"];

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void submitRequest() {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
      return;
    }

    Get.snackbar("Success", "Maintenance request submitted!");
    
    // Clear and go back
    titleController.clear();
    descController.clear();
    Get.back();
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    super.onClose();
  }
}
