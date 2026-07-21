import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _roomController.loadRooms(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _roomController.loadMoreRooms();
    }
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
        actions: const [],
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
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                // Minimap Section
                Text(
                  'Quick Map View',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: const LatLng(27.7042, 85.3082), // Kathmandu center
                            initialZoom: 11.5,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.roomrental.app',
                            ),
                            MarkerLayer(
                              markers: _rooms.where((r) =>
                                r.latitude != null &&
                                r.longitude != null &&
                                double.tryParse(r.latitude.toString()) != 0.0 &&
                                double.tryParse(r.longitude.toString()) != 0.0
                              ).map((room) {
                                final lat = double.tryParse(room.latitude.toString()) ?? 27.7042;
                                final lng = double.tryParse(room.longitude.toString()) ?? 85.3082;
                                return Marker(
                                  point: LatLng(lat, lng),
                                  width: 32,
                                  height: 32,
                                  child: GestureDetector(
                                    onTap: () => Get.to(() => RoomDetailView(roomId: room.id ?? 0)),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      size: 26,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        // Expand Map overlay button
                        Positioned(
                          top: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () => Get.to(() => const ExploreMapView()),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.fullscreen_rounded,
                                size: 20,
                                color: Colors.blueAccent.shade700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (_recommended.isNotEmpty) ...[
                  Text(
                    'Recommended',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (_rooms.isEmpty)
                  const _EmptyState(
                    icon: Icons.home_work_outlined,
                    title: 'No rooms available',
                    subtitle: 'Try again later for fresh listings.',
                  )
                else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rooms.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return _RoomCard(
                        room: room,
                        onTap: () =>
                            Get.to(() => RoomDetailView(roomId: room.id ?? 0)),
                      );
                    },
                  ),
                  Obx(() {
                    if (_roomController.isLoadMoreLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (!_roomController.hasNextPage.value &&
                        _rooms.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'No more rooms available',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: Colors.blue.shade50,
                              child: Center(
                                child: Icon(
                                  Icons.home_work_outlined,
                                  size: 32,
                                  color: Colors.blueAccent.shade700,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.blue.shade50,
                            child: Center(
                              child: Icon(
                                Icons.home_work_outlined,
                                size: 32,
                                color: Colors.blueAccent.shade700,
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
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${room.genderPreference!.toUpperCase()} ONLY',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // Amenity icons
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Row(
                    children: [
                      if (room.hasWifi == true) _buildAmenityIcon(Icons.wifi),
                      if (room.hasAc == true) _buildAmenityIcon(Icons.ac_unit),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title ?? 'Room',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${room.province ?? ''}, ${room.state ?? ''}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Rs. ${room.price ?? '0'}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  fontSize: 14,
                                ),
                          ),
                          Text(
                            '/month',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
                          ),
                        ],
                      ),
                      if (room.landlord?.username != null)
                        Text(
                          'by ${room.landlord!.username}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
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
      child: Icon(icon, color: Colors.white, size: 14),
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 210,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 115,
                    width: double.infinity,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: Colors.blue.shade50,
                              child: Center(
                                child: Icon(
                                  Icons.home_work_outlined,
                                  size: 32,
                                  color: Colors.blueAccent.shade700,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.blue.shade50,
                            child: Center(
                              child: Icon(
                                Icons.home_work_outlined,
                                size: 32,
                                color: Colors.blueAccent.shade700,
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
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${room.genderPreference!.toUpperCase()} ONLY',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // Amenity icons
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Row(
                    children: [
                      if (room.hasWifi == true) _buildAmenityIcon(Icons.wifi),
                      if (room.hasAc == true) _buildAmenityIcon(Icons.ac_unit),
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
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title ?? 'Room',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${room.province ?? ''}, ${room.state ?? ''}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Rs. ${room.price ?? '0'}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  fontSize: 13,
                                ),
                          ),
                        ],
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
      child: Icon(icon, color: Colors.white, size: 14),
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
