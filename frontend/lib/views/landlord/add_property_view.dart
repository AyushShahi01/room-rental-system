import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_rental_system/controllers/property_controller.dart';
import 'package:room_rental_system/controllers/dashboard_controller.dart';

class AddPropertyView extends StatelessWidget {
  const AddPropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    final PropertyController ctrl = Get.find<PropertyController>();

    final titleCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add New Room",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                  hintText: "E.g., Beautiful Double Room",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(
                  labelText: "Price (NPR)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              Obx(
                () => GestureDetector(
                  onTap: () {
                    _showImagePickerOptions(context, ctrl);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      image: ctrl.pickedImagePath.value.isNotEmpty
                          ? (kIsWeb
                              ? DecorationImage(
                                  image: NetworkImage(ctrl.pickedImagePath.value),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: FileImage(
                                    File(ctrl.pickedImagePath.value),
                                  ),
                                  fit: BoxFit.cover,
                                ))
                          : null,
                    ),
                    child: ctrl.pickedImagePath.value.isEmpty
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap to add photos",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (titleCtrl.text.isEmpty ||
                        locationCtrl.text.isEmpty ||
                        priceCtrl.text.isEmpty) {
                      Get.snackbar(
                        "Error",
                        "Please fill required fields",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    ctrl.addProperty(
                      title: titleCtrl.text,
                      location: locationCtrl.text,
                      price: int.tryParse(priceCtrl.text) ?? 0,
                      bedrooms: 1,
                      bathrooms: 1,
                      hasWifi: false,
                      localImagePath: ctrl.pickedImagePath.value.isNotEmpty
                          ? ctrl.pickedImagePath.value
                          : null,
                    );

                    Get.snackbar(
                      "Success",
                      "Property published successfully",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    ctrl.clearImage();
                    titleCtrl.clear();
                    locationCtrl.clear();
                    priceCtrl.clear();
                    descCtrl.clear();

                    if (Get.isRegistered<DashboardController>()) {
                      Get.find<DashboardController>().changeTab(0);
                    }
                  },
                  child: const Text(
                    "Publish Listing",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, PropertyController ctrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () {
                ctrl.pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                ctrl.pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
