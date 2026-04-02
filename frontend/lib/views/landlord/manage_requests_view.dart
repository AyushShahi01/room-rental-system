import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/maintenance_controller.dart';

class ManageRequestsView extends StatelessWidget {
  const ManageRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController bookingCtrl = Get.find<BookingController>();
    final MaintenanceController maintenanceCtrl = Get.find<MaintenanceController>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Inbox & Requests", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Booking Requests Section
              Row(
                children: [
                  const Icon(Icons.book_online, color: Colors.teal),
                  const SizedBox(width: 8),
                  const Text("Room Booking Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (bookingCtrl.bookings.isEmpty) {
                  return _buildEmptyState("No room booking requests.");
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookingCtrl.bookings.length,
                  itemBuilder: (context, index) {
                    final req = bookingCtrl.bookings[index];
                    return GestureDetector(
                      onTap: () => _showTenantProfileSheet(
                        req.userName, req.userAddress, req.userPhone
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.teal,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(req.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text("Requested: ${req.room?.title ?? 'Unknown'}", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  _buildStatusBadge(req.status),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Obx(() {
                                if (req.status.value == 'Pending') {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => bookingCtrl.rejectRequest(req.id),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                                          ),
                                          child: const Text("Reject"),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => bookingCtrl.approveRequest(req.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal, foregroundColor: Colors.white,
                                          ),
                                          child: const Text("Approve"),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink(); // Hide buttons if handled
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 32),

              // Maintenance Requests Section
              Row(
                children: [
                  const Icon(Icons.build_circle, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text("Maintenance Issues", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (maintenanceCtrl.maintenanceRequests.isEmpty) {
                  return _buildEmptyState("No maintenance requests.");
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: maintenanceCtrl.maintenanceRequests.length,
                  itemBuilder: (context, index) {
                    final req = maintenanceCtrl.maintenanceRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Text(req.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                Obx(() {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: req.status.value == 'Pending' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(req.status.value, style: TextStyle(
                                      color: req.status.value == 'Pending' ? Colors.orange : Colors.green, fontWeight: FontWeight.bold, fontSize: 12
                                    )),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text("Tenant: ${req.tenantName} (${req.roomTitle})", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal)),
                            const SizedBox(height: 4),
                            Text(req.description, style: TextStyle(color: Colors.grey.shade800)),
                            const SizedBox(height: 12),
                            Obx(() {
                              if (req.status.value == 'Pending') {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => maintenanceCtrl.resolveRequest(req.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange, foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Mark as Resolved"),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(child: Text(msg, style: TextStyle(color: Colors.grey.shade500))),
    );
  }

  Widget _buildStatusBadge(RxString status) {
    return Obx(() {
      Color c = status.value == 'Approved' ? Colors.green : (status.value == 'Rejected' ? Colors.red : Colors.orange);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
           color: c.withOpacity(0.1),
           borderRadius: BorderRadius.circular(20),
        ),
        child: Text(status.value, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 12)),
      );
    });
  }

  void _showTenantProfileSheet(String name, String address, String phone) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            const CircleAvatar(radius: 40, backgroundColor: Colors.teal, child: Icon(Icons.person, size: 40, color: Colors.white)),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Tenant Applicant", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.teal),
              title: const Text("Phone"),
              subtitle: Text(phone),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.teal),
              title: const Text("Address/Email"),
              subtitle: Text(address),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                onPressed: () => Get.back(),
                child: const Text("Close"),
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
