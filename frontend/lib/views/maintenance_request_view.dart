import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/maintenance_controller.dart';

class MaintenanceRequestView extends StatelessWidget {
  const MaintenanceRequestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MaintenanceController ctrl = Get.find<MaintenanceController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Issue Title
            const Text('Issue Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl.titleController,
              decoration: const InputDecoration(
                hintText: 'E.g., Broken Sink',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: ctrl.selectedCategory.value,
                      items: ctrl.categories.map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) ctrl.setCategory(val);
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // Description Field
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl.descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the issue clearly...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Upload Photo Button
            const Text('Add Photo (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Get.snackbar("Photo", "UI only: Camera/Gallery trigger");
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Upload Photo'),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: ctrl.submitRequest,
                child: const Text('Submit Request', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
