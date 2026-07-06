import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tenant_dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/room/room_model.dart' as room_model;
import '../../models/auth_model/user_model.dart';
import '../../models/booking/booking_model.dart';

import '../message/chat_detail_view.dart';
import '../room/room_detail_view.dart';
import 'tenant_maintenance_view.dart';
import 'tenant_rent_ledger_view.dart';
import '../explore_map_view.dart';

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
                      controller: controller.searchController,
                      onChanged: (val) {
                        controller.performSearch(val);
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.map_outlined,
                            color: Colors.blueAccent.shade700,
                          ),
                          onPressed: () => Get.to(() => const ExploreMapView()),
                          tooltip: 'Explore on Map',
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

                  final isSearch = controller.isSearchMode.value;
                  final selectedTag = controller.selectedFilterTag.value;
                  var rooms = isSearch
                      ? controller.searchResults.cast<room_model.Result>()
                      : controller.allProperties.cast<room_model.Result>();

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
                  if (rooms.isEmpty && !isSearch) {
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
                                        color: Colors.indigo.shade700,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'My Bookings',
                                        style: TextStyle(
                                          color: Colors.indigo.shade700,
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
                        const SizedBox(height: 24),

                        Text(
                          isSearch ? 'Search Results' : 'Available Rooms',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (rooms.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No rooms match your search query.',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ExploreMapView()),
        backgroundColor: Colors.indigo.shade800,
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
          colors: [Colors.indigo.shade800, Colors.blueAccent.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade900.withValues(alpha: 0.25),
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
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.meeting_room,
                          color: Colors.white38,
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
                          foregroundColor: Colors.indigo.shade800,
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
                          Icons.payments_outlined,
                          size: 16,
                          color: Colors.indigo.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rs. ${room.price ?? '0'}',
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
