import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/maintenance_controller.dart';
import '../../../models/room/room_model.dart';

class TenantMaintenanceView extends StatelessWidget {
  const TenantMaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazily initialize controller
    final controller = Get.put(MaintenanceController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Maintenance Request', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequestForm(controller, context),
            const SizedBox(height: 32),
            const Text(
              'Recent Requests',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _buildRecentRequests(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestForm(MaintenanceController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Obx(() {
            final bool hasRooms = controller.myRooms.isNotEmpty;
            return DropdownButtonFormField<Result>(
              decoration: InputDecoration(
                labelText: hasRooms ? 'Select Room' : 'No approved rooms available',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              value: hasRooms ? controller.selectedRoom.value : null,
              items: controller.myRooms.map((room) {
                return DropdownMenuItem(
                  value: room,
                  child: Text(room.title ?? 'Unknown Room'),
                );
              }).toList(),
              onChanged: hasRooms ? (val) {
                if (val != null) controller.selectedRoom.value = val;
              } : null,
            );
          }),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: controller.titleController,
            decoration: InputDecoration(
              labelText: 'Issue Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Obx(() {
            return DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              value: controller.selectedCategory.value,
              items: controller.categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) {
                if (val != null) controller.selectedCategory.value = val;
              },
            );
          }),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: controller.descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Image picking has been removed per requirements.
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: Obx(() {
              return ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.submitRequest(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests(MaintenanceController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.maintenanceList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.maintenanceList.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No maintenance requests found.', style: TextStyle(color: Colors.grey)),
          ),
        );
      }
      
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.maintenanceList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final req = controller.maintenanceList[index];

          // Parse formatted description: "Category: ...\nTitle: ...\n\n..."
          String cardTitle = 'Request #${req.id}';
          String cardCategory = '';
          String cardDesc = req.description ?? '';
          if (cardDesc.startsWith('Category:')) {
            final parts = cardDesc.split('\n');
            if (parts.length >= 3) {
              cardCategory = parts[0].replaceFirst('Category: ', '').trim();
              cardTitle = parts[1].replaceFirst('Title: ', '').trim();
              cardDesc = parts.sublist(2).join('\n').trim();
            }
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cardTitle,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStatusChip(req.status ?? 'pending'),
                    ],
                  ),
                  if (cardCategory.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.category, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(cardCategory, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ],
                  if (cardDesc.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      cardDesc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                  if (req.createdAt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 13, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '${req.createdAt!.toLocal()}'.split(' ')[0],
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                  // ── Image uploaded with the request ──────────────────────
                  if (req.image != null && req.image!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        req.image!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 160,
                            color: Colors.grey.shade100,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          height: 80,
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    });
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
    
    return Chip(
      label: Text(status.toUpperCase(), style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
      backgroundColor: bgColor,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
