import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/landlord_dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/auth_model/user_model.dart';
import '../../routes/app_routes.dart';
import 'landlord_maintenance_view.dart';
import '../payment_history_view.dart';

class LandlordDashboard extends StatelessWidget {
  const LandlordDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LandlordDashboardController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            tooltip: 'Notifications',
          ),
          Obx(() {
            final user = authController.currentUser.value;
            final picUrl = user?.absoluteProfilePictureUrl;
            return GestureDetector(
              onTap: () => controller.onItemTapped(4),
              child: Container(
                margin: const EdgeInsets.only(right: 16, left: 8, top: 10, bottom: 10),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.indigo.shade200,
                    width: 1.5,
                  ),
                ),
                child: picUrl != null && picUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          picUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _appBarInitials(user),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.indigo,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : _appBarInitials(user),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadDashboardData,
          color: Colors.indigo.shade700,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome / Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Landlord Hub',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      final user = authController.currentUser.value;
                      final displayName =
                          user?.firstName ?? authController.userName.value;
                      return Text(
                        'Welcome, $displayName ',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                // API Status Banner
                Obx(() {
                  final message = controller.dashboardData.value?.message;
                  if (message == null || message.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade700.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.indigo.shade700.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.indigo.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),

                // Metrics Grid
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.totalRooms.value == 0) {
                    return const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Total Rooms',
                              value: '${controller.totalRooms.value}',
                              icon: Icons.meeting_room,
                              color: Colors.blue.shade600,
                              onTap: () => controller.selectedIndex.value = 1,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Booking Requests',
                              value: '${controller.pendingBookings.value}',
                              icon: Icons.pending_actions,
                              color: Colors.orange.shade700,
                              onTap: () => controller.selectedIndex.value = 2,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Rent Collected',
                              value:
                                  '₹${controller.totalRentCollected.value.toStringAsFixed(0)}',
                              icon: Icons.monetization_on,
                              color: Colors.green.shade600,
                              onTap: () =>
                                  Get.to(() => const PaymentHistoryView()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Pending Rent',
                              value:
                                  '₹${controller.totalPendingRent.value.toStringAsFixed(0)}',
                              icon: Icons.hourglass_empty,
                              color: Colors.orange.shade700,
                              onTap: () =>
                                  Get.to(() => const PaymentHistoryView()),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Overdue Rent Accounts',
                              value: '${controller.overdueTenantsCount.value}',
                              icon: Icons.warning_amber_rounded,
                              color: Colors.red.shade700,
                              onTap: () =>
                                  Get.to(() => const PaymentHistoryView()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'Maintenance',
                              value: '${controller.maintenanceRequests.value}',
                              icon: Icons.build,
                              color: Colors.purple.shade600,
                              onTap: () =>
                                  Get.to(() => const LandlordMaintenanceView()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 28),

                // Quick Action Buttons
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'Add New Room',
                        subtitle: 'List a room for rent',
                        icon: Icons.add_circle_outline,
                        gradient: [Colors.indigo.shade700, Colors.indigo.shade500],
                        onTap: () {
                          controller.selectedIndex.value = 1;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Verify Payments',
                        subtitle: 'Approve tenant logs',
                        icon: Icons.check_circle_outline,
                        gradient: [Colors.teal.shade700, Colors.teal.shade500],
                        onTap: () => Get.to(() => const PaymentHistoryView()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Recent Activities
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),

                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.recentActivities.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'No recent activities.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.recentActivities.length,
                    itemBuilder: (context, index) {
                      final activity = controller.recentActivities[index];

                      IconData iconData;
                      Color iconColor;
                      if (activity.type == 'room') {
                        iconData = Icons.meeting_room;
                        iconColor = Colors.blue.shade600;
                      } else if (activity.type == 'maintenance') {
                        iconData = Icons.build;
                        iconColor = Colors.purple.shade600;
                      } else if (activity.type == 'rent') {
                        iconData = Icons.warning_rounded;
                        iconColor = Colors.red.shade700;
                      } else {
                        iconData = Icons.bookmark;
                        iconColor = Colors.orange.shade700;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: iconColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    iconData,
                                    color: iconColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activity.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        activity.subtitle,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (activity.type == 'booking' &&
                                activity.data != null &&
                                activity.data.status == 'pending')
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => controller.rejectBooking(
                                        activity.data.id as int,
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          controller.approveBooking(
                                            activity.data.id as int,
                                          ),
                                      child: const Text('Approve'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'cancelled':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _appBarInitials(UserModel? user) {
    final first = user?.firstName;
    final last = user?.lastName;
    final username = user?.username;
    String initials = '?';
    if ((first ?? '').isNotEmpty && (last ?? '').isNotEmpty) {
      initials = '${first![0]}${last![0]}'.toUpperCase();
    } else if ((first ?? '').isNotEmpty) {
      initials = first![0].toUpperCase();
    } else if ((username ?? '').isNotEmpty) {
      initials = username![0].toUpperCase();
    }
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.indigo,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
