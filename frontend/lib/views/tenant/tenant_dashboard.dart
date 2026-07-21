import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tenant_dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/room/room_model.dart' as room_model;
import '../../models/auth_model/user_model.dart';
import '../../models/booking/booking_model.dart';
import '../../controllers/notification_controller.dart';
import '../../routes/app_routes.dart';

import '../message/chat_detail_view.dart';
import '../room/room_detail_view.dart';
import 'tenant_maintenance_view.dart';
import 'tenant_rent_ledger_view.dart';
import '../explore_map_view.dart';
import '../searchpage_view.dart';

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
          _buildNotificationIcon(),
          Obx(() {
            final user = authController.currentUser.value;
            final picUrl = user?.absoluteProfilePictureUrl;
            return GestureDetector(
              onTap: () => controller.onItemTapped(4),
              child: Container(
                margin: const EdgeInsets.only(
                  right: 16,
                  left: 8,
                  top: 10,
                  bottom: 10,
                ),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueAccent.shade100,
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
                                  color: Colors.blueAccent,
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
          color: Colors.blueAccent.shade700,
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

                // 1.5 Active Stay Card Section
                Obx(() {
                  final active = controller.activeBooking.value;
                  if (active != null) {
                    return _buildActiveStayCard(active);
                  }
                  return const SizedBox.shrink();
                }),

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
                      readOnly: true,
                      onTap: () {
                        Get.to(() => const SearchpageView());
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name only',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade500,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.tune_rounded,
                            color: Colors.blueAccent.shade700,
                          ),
                          onPressed: () => _showFilterBottomSheet(context, controller),
                          tooltip: 'Filter Rooms',
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // 2.5 Quick Feature Filter Tags
                _buildFilterTags(controller),

                const SizedBox(height: 24),

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

                  final selectedTag = controller.selectedFilterTag.value;
                  var rooms = controller.allProperties.cast<room_model.Result>();

                  if (selectedTag.isNotEmpty) {
                    rooms = rooms.where((room) {
                      if (selectedTag == 'Wi-Fi') return room.hasWifi == true;
                      if (selectedTag == 'AC') return room.hasAc == true;
                      if (selectedTag == 'Furnished')
                        return room.furnishedStatus == true;
                      if (selectedTag == 'Parking')
                        return room.parkingAvailable == true;
                      if (selectedTag == 'Bath')
                        return room.hasAttachedBathroom == true;
                      return true;
                    }).toList();
                  }

                  // Apply advanced filters
                  rooms = rooms.where((room) {
                    final double price = double.tryParse(room.price ?? '0') ?? 0.0;
                    if (price > controller.maxPrice.value) return false;
                    
                    if (controller.filterWifi.value && room.hasWifi != true) return false;
                    if (controller.filterAc.value && room.hasAc != true) return false;
                    if (controller.filterFurnished.value && room.furnishedStatus != true) return false;
                    if (controller.filterParking.value && room.parkingAvailable != true) return false;
                    if (controller.filterBath.value && room.hasAttachedBathroom != true) return false;
                    
                    if (controller.filterGender.value != 'any') {
                      if (room.genderPreference?.toLowerCase() != 'any' && 
                          room.genderPreference?.toLowerCase() != controller.filterGender.value.toLowerCase()) {
                        return false;
                      }
                    }
                    return true;
                  }).toList();
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                    onTap: () =>
                                        Get.to(() => const TenantMaintenanceView()),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
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
                                          const Icon(
                                            Icons.build,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Maintenance',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => controller.selectedIndex.value =
                                        2, // Go to bookings
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
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
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.blueAccent.shade700,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'My Bookings',
                                            style: TextStyle(
                                              color: Colors.blueAccent.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        Get.to(() => const TenantRentLedgerView()),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade700,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.teal.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.receipt_long,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Rent Ledger',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Recommendations Section (Horizontal)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Recommendations',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: Obx(() {
                          var recs = controller.recommendedRooms.cast<room_model.Result>().toList();
                          
                          // Apply advanced filters to recommendations
                          recs = recs.where((room) {
                            final double price = double.tryParse(room.price ?? '0') ?? 0.0;
                            if (price > controller.maxPrice.value) return false;
                            
                            if (controller.filterWifi.value && room.hasWifi != true) return false;
                            if (controller.filterAc.value && room.hasAc != true) return false;
                            if (controller.filterFurnished.value && room.furnishedStatus != true) return false;
                            if (controller.filterParking.value && room.parkingAvailable != true) return false;
                            if (controller.filterBath.value && room.hasAttachedBathroom != true) return false;
                            
                            if (controller.filterGender.value != 'any') {
                              if (room.genderPreference?.toLowerCase() != 'any' && 
                                  room.genderPreference?.toLowerCase() != controller.filterGender.value.toLowerCase()) {
                                return false;
                              }
                            }
                            return true;
                          }).toList();

                          if (recs.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Center(
                                child: Text(
                                  'No recommendations match your filter.',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: recs.length,
                            itemBuilder: (context, index) {
                              final room = recs[index];
                              return _RecommendedRoomCard(room: room);
                            },
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // Recent Rooms Section (Vertical)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Recent Rooms',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (rooms.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'No recent rooms match your filter.',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                ),
                              )
                            else
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
                            if (controller.hasNextPage.value)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: controller.isLoadMoreLoading.value
                                      ? const CircularProgressIndicator()
                                      : ElevatedButton(
                                          onPressed: controller.loadMoreRooms,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Load More'),
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ExploreMapView()),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.map_outlined),
        label: const Text(
          'Map View',
          style: TextStyle(fontWeight: FontWeight.bold),
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
        color: Colors.blueAccent,
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

  Widget _buildActiveStayCard(BookingModel booking) {
    String? imageUrl;
    if (booking.roomImages.isNotEmpty) {
      imageUrl = booking.roomImages.first;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blueAccent.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.home, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Active Stay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rent: Rs. ${booking.roomPrice ?? '0'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http'))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.home_work_outlined,
                              color: Colors.blueAccent.shade700,
                              size: 20,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.home_work_outlined,
                          color: Colors.blueAccent.shade700,
                          size: 20,
                        ),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.roomTitle ?? 'Cozy Room',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Landlord: ${booking.landlordName ?? 'Unknown'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          if (booking.landlord != null) {
                            Get.to(
                              () => ChatDetailView(partner: booking.landlord!),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: const Text(
                          'Landlord',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () =>
                            Get.to(() => const TenantMaintenanceView()),
                        icon: const Icon(
                          Icons.build_circle_outlined,
                          color: Colors.black,
                          size: 16,
                        ),
                        label: const Text(
                          'Maintenance',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTags(TenantDashboardController controller) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 14),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.filterTags.length,
        itemBuilder: (context, index) {
          final tag = controller.filterTags[index];
          return Obx(() {
            final isSelected = controller.selectedFilterTag.value == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.blueAccent.shade700,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.shade200,
                  ),
                ),
                showCheckmark: false,
                onSelected: (_) => controller.toggleFilterTag(tag),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildNotificationIcon() {
    final notificationController = Get.find<NotificationController>();
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 28,
            color: Colors.black87,
          ),
          onPressed: () async {
            await Get.toNamed(AppRoutes.notifications);
            notificationController.fetchNotifications();
          },
        ),
        Obx(() {
          final count = notificationController.unreadCount;
          if (count == 0) return const SizedBox.shrink();
          return Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context, TenantDashboardController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.resetFilters();
                    },
                    child: const Text('Reset All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Max Price
              const Text(
                'Max Budget (per month)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Column(
                children: [
                  Slider(
                    value: controller.maxPrice.value,
                    min: 1000.0,
                    max: 100000.0,
                    divisions: 99,
                    activeColor: Colors.blueAccent.shade700,
                    inactiveColor: Colors.blue.shade50,
                    label: 'Rs. ${controller.maxPrice.value.round()}',
                    onChanged: (val) {
                      controller.maxPrice.value = val;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rs. 1,000', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text(
                        'Rs. ${controller.maxPrice.value.round()}',
                        style: TextStyle(
                          color: Colors.blueAccent.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text('Rs. 100,000', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ],
              )),
              const SizedBox(height: 24),

              // Amenities
              const Text(
                'Amenities',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    label: 'Wi-Fi',
                    isSelected: controller.filterWifi.value,
                    onSelected: (val) => controller.filterWifi.value = val,
                  ),
                  _buildFilterChip(
                    label: 'Air Conditioning',
                    isSelected: controller.filterAc.value,
                    onSelected: (val) => controller.filterAc.value = val,
                  ),
                  _buildFilterChip(
                    label: 'Furnished',
                    isSelected: controller.filterFurnished.value,
                    onSelected: (val) => controller.filterFurnished.value = val,
                  ),
                  _buildFilterChip(
                    label: 'Parking Space',
                    isSelected: controller.filterParking.value,
                    onSelected: (val) => controller.filterParking.value = val,
                  ),
                  _buildFilterChip(
                    label: 'Attached Bathroom',
                    isSelected: controller.filterBath.value,
                    onSelected: (val) => controller.filterBath.value = val,
                  ),
                ],
              )),
              const SizedBox(height: 24),

              // Gender Preference
              const Text(
                'Gender Preference',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => Row(
                children: [
                  _buildGenderButton(
                    label: 'Any',
                    value: 'any',
                    groupValue: controller.filterGender.value,
                    onTap: () => controller.filterGender.value = 'any',
                  ),
                  const SizedBox(width: 8),
                  _buildGenderButton(
                    label: 'Male',
                    value: 'male',
                    groupValue: controller.filterGender.value,
                    onTap: () => controller.filterGender.value = 'male',
                  ),
                  const SizedBox(width: 8),
                  _buildGenderButton(
                    label: 'Female',
                    value: 'female',
                    groupValue: controller.filterGender.value,
                    onTap: () => controller.filterGender.value = 'female',
                  ),
                ],
              )),
              const SizedBox(height: 24),

              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Colors.blueAccent.shade100.withOpacity(0.3),
      checkmarkColor: Colors.blueAccent.shade700,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blueAccent.shade700 : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required String value,
    required String groupValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == groupValue;
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blueAccent.shade700 : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label),
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
                child:
                    imageUrl != null &&
                        imageUrl.isNotEmpty &&
                        imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.blue.shade50,
                          child: Icon(
                            Icons.home_work_outlined,
                            color: Colors.blueAccent.shade700,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.blue.shade50,
                        child: Icon(
                          Icons.home_work_outlined,
                          color: Colors.blueAccent.shade700,
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
                          Icons.payments_outlined,
                          size: 16,
                          color: Colors.blueAccent.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rs. ${room.price ?? '0'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent.shade700,
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

class _RecommendedRoomCard extends StatelessWidget {
  const _RecommendedRoomCard({required this.room});

  final room_model.Result room;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _extractImageUrl(room.images);

    return InkWell(
      onTap: () => Get.to(() => RoomDetailView(roomId: room.id ?? 0)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: imageUrl != null &&
                        imageUrl.isNotEmpty &&
                        imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.blue.shade50,
                          child: Icon(
                            Icons.home_work_outlined,
                            color: Colors.blueAccent.shade700,
                            size: 32,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.blue.shade50,
                        child: Icon(
                          Icons.home_work_outlined,
                          color: Colors.blueAccent.shade700,
                          size: 32,
                        ),
                      ),
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title ?? 'Recommended Room',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${room.province ?? ''}, ${room.state ?? ''}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rs. ${room.price ?? '0'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blueAccent.shade700,
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

  String? _extractImageUrl(List<dynamic>? images) {
    if (images == null || images.isEmpty) return null;
    if (images.first is room_model.RoomImage) {
      final roomImage = images.first as room_model.RoomImage;
      return roomImage.image;
    }
    return null;
  }
}


