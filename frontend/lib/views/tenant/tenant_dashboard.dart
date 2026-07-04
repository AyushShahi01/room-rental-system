import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tenant_dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/room/room_model.dart' as room_model;
import '../../routes/app_routes.dart';
import '../room/room_detail_view.dart';
import 'tenant_maintenance_view.dart';

class TenantDashboard extends StatelessWidget {
  const TenantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TenantDashboardController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(AppRoutes.settings),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadDashboardData,
          color: Colors.indigo.shade700,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. App Bar Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Your Cozy Home',
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
                          'Hello, $displayName 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // 2. Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: (val) {
                        controller.performSearch(val);
                        controller.selectedIndex.value =
                            1; // switch to search tab
                      },
                      decoration: InputDecoration(
                        hintText: 'Search city, state or room name...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 3. Rooms from the API
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: controller.loadDashboardData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final rooms =
                      controller.dashboardData.value?.results ??
                      <room_model.Result>[];
                  if (rooms.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No rooms are available right now.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Actions
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => Get.to(() => const TenantMaintenanceView()),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.shade700,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.build, color: Colors.white, size: 28),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Maintenance',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: () => controller.selectedIndex.value = 2, // Go to bookings
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.indigo.shade700, size: 28),
                                      const SizedBox(height: 8),
                                      Text(
                                        'My Bookings',
                                        style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        Text(
                          'Available Rooms',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: rooms.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            return _RoomCard(room: room, context: context);
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.context});

  final room_model.Result room;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _extractImageUrl(room.images);

    return InkWell(
      onTap: () => Get.to(() => RoomDetailView(roomId: room.id ?? 0)),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: SizedBox(
                width: 110,
                height: 110,
                child: imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.indigo.shade50,
                          child: Icon(
                            Icons.home_work_outlined,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.indigo.shade50,
                        child: Icon(
                          Icons.home_work_outlined,
                          color: Colors.indigo.shade700,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title ?? 'Room',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${room.province ?? ''}, ${room.state ?? ''}'.trim(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money_rounded,
                          size: 16,
                          color: Colors.indigo.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₹${room.price ?? '0'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _extractImageUrl(List<dynamic>? images) {
    if (images == null || images.isEmpty) return null;
    if (images.first is room_model.RoomImage) {
      final roomImage = images.first as room_model.RoomImage;
      return roomImage.image;
    }
    return null;
  }
}
