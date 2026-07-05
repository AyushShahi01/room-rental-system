import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/room_controller.dart';
import '../../models/room/room_model.dart';
import '../../models/room/recommendation_model.dart' as rec_model;
import '../../utils/dio_connection.dart';
import '../room/room_detail_view.dart';
import '../explore_map_view.dart';

class TenantRoomsView extends StatefulWidget {
  const TenantRoomsView({super.key});

  @override
  State<TenantRoomsView> createState() => _TenantRoomsViewState();
}

class _TenantRoomsViewState extends State<TenantRoomsView> {
  final RoomController _roomController = Get.put(RoomController());

  @override
  void initState() {
    super.initState();
    _roomController.loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.2,
      ),
      appBar: AppBar(
        title: const Text(
          'Explore Rooms',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'View on Map',
            onPressed: () => Get.to(() => const ExploreMapView()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _roomController.loadRooms,
        child: Obx(() {
          if (_roomController.isRoomsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final _rooms = _roomController.rooms;
          final _recommended = _roomController.recommendedRooms;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_recommended.isNotEmpty) ...[
                  Text(
                    'Recommended',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommended.length,
                      padding: const EdgeInsets.only(right: 16),
                      itemBuilder: (context, index) {
                        final recommendation = _recommended[index];
                        final room = recommendation.room;
                        if (room == null) return const SizedBox();
                        
                        return _RecommendationCard(
                          room: room,
                          onTap: () => Get.to(
                            () => RoomDetailView(roomId: room.id ?? 0),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  'Available Rooms',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_rooms.isEmpty)
                  const _EmptyState(
                    icon: Icons.home_work_outlined,
                    title: 'No rooms available',
                    subtitle: 'Try again later for fresh listings.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rooms.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return _RoomCard(
                        room: room,
                        onTap: () => Get.to(
                          () => RoomDetailView(roomId: room.id ?? 0),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.onTap});

  final Result room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = room.images.isNotEmpty ? room.images.first.image : null;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              child: Center(
                                child: Icon(
                                  Icons.home_work_outlined,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            child: Center(
                              child: Icon(
                                Icons.home_work_outlined,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                  ),
                ),
                // Gender badge
                if (room.genderPreference != null &&
                    room.genderPreference!.isNotEmpty &&
                    room.genderPreference!.toLowerCase() != 'any' &&
                    room.genderPreference!.toLowerCase() != 'co-ed')
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${room.genderPreference!.toUpperCase()} ONLY',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // Amenity icons
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Row(
                    children: [
                      if (room.hasWifi == true)
                        _buildAmenityIcon(Icons.wifi),
                      if (room.hasAc == true)
                        _buildAmenityIcon(Icons.ac_unit),
                      if (room.parkingAvailable == true)
                        _buildAmenityIcon(Icons.local_parking),
                      if (room.hasAttachedBathroom == true)
                        _buildAmenityIcon(Icons.bathtub_outlined),
                      if (room.furnishedStatus == true)
                        _buildAmenityIcon(Icons.chair_outlined),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title ?? 'Room',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${room.province ?? ''}, ${room.state ?? ''}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '₹${room.price ?? '0'}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '/month',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (room.landlord?.username != null)
                        Text(
                          'by ${room.landlord!.username}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 14,
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.room, required this.onTap});

  final rec_model.Room room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (room.images.isNotEmpty) {
      final img = room.images.first;
      if (img is Map) {
        imageUrl = img['image']?.toString();
      } else if (img is String) {
        imageUrl = img;
      }
    }
    
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      final prefix = imageUrl.startsWith('/') ? '' : '/';
      imageUrl = '${DioConnection.baseDomain}$prefix$imageUrl';
    }
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              child: Center(
                                child: Icon(
                                  Icons.home_work_outlined,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            child: Center(
                              child: Icon(
                                Icons.home_work_outlined,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                  ),
                ),
                // Gender badge
                if (room.genderPreference != null &&
                    room.genderPreference!.isNotEmpty &&
                    room.genderPreference!.toLowerCase() != 'any' &&
                    room.genderPreference!.toLowerCase() != 'co-ed')
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${room.genderPreference!.toUpperCase()} ONLY',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // Amenity icons
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Row(
                    children: [
                      if (room.hasWifi == true)
                        _buildAmenityIcon(Icons.wifi),
                      if (room.hasAc == true)
                        _buildAmenityIcon(Icons.ac_unit),
                      if (room.parkingAvailable == true)
                        _buildAmenityIcon(Icons.local_parking),
                      if (room.hasAttachedBathroom == true)
                        _buildAmenityIcon(Icons.bathtub_outlined),
                      if (room.furnishedStatus == true)
                        _buildAmenityIcon(Icons.chair_outlined),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title ?? 'Room',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${room.province ?? ''}, ${room.state ?? ''}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '₹${room.price ?? '0'}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (room.landlord?.username != null)
                        Text(
                          'by ${room.landlord!.username}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 14,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
