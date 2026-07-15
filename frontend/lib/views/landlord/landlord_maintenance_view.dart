import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/maintenance_controller.dart';
import '../../../models/maintenace/maintenance_model.dart';

class LandlordMaintenanceView extends StatelessWidget {
  const LandlordMaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazily initialize controller
    final controller = Get.put(MaintenanceController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('All Maintenance Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent.shade700,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchMaintenanceRequests(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.maintenanceList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.maintenanceList.isEmpty) {
          return const Center(
            child: Text('No maintenance requests found.', style: TextStyle(color: Colors.grey, fontSize: 16)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.maintenanceList.length,
          itemBuilder: (context, index) {
            final req = controller.maintenanceList[index];
            return _buildMaintenanceCard(req, controller, context);
          },
        );
      }),
    );
  }

  Widget _buildMaintenanceCard(MaintenanceModel req, MaintenanceController controller, BuildContext context) {
    // Parse the description if it's formatted as "Category: ... \nTitle: ... \n\n..."
    String title = 'Request #${req.id}';
    String category = 'Unknown';
    String desc = req.description ?? '';

    if (desc.startsWith('Category:')) {
      final parts = desc.split('\n');
      if (parts.length >= 3) {
        category = parts[0].replaceFirst('Category: ', '').trim();
        title = parts[1].replaceFirst('Title: ', '').trim();
        desc = parts.sublist(2).join('\n').trim();
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildStatusChip(req.status ?? 'pending'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(category, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                Icon(Icons.door_front_door, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('Room ${req.room}', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(req.tenantDisplay, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  req.createdAt != null ? '${req.createdAt!.toLocal()}'.split(' ')[0] : 'Unknown Date',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 14)),
            
            if (req.image != null && req.image!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  req.image!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: (req.status?.toLowerCase() ?? 'pending') == 'completed' ? 'resolved' : (req.status?.toLowerCase() ?? 'pending'),
                    items: const [
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                    ],
                    onChanged: (val) {
                      if (val != null && val != req.status?.toLowerCase()) {
                        controller.updateStatus(req.id!, val);
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'completed':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'in_progress':
      case 'in progress':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      default:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
