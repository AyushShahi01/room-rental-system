import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/room_controller.dart';
import '../../models/room/room_model.dart';
import '../../models/room/recommendation_model.dart' as rec_model;
import '../../utils/dio_connection.dart';
import '../room/room_detail_view.dart';

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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                        errorBuilder: (_, _, _) => SizedBox(
                          height: 140,
                          child: Center(
                            child: Icon(
                              Icons.home_work_outlined,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 140,
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
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title ?? 'Room',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${room.province ?? ''}, ${room.state ?? ''}'.trim(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹${room.price ?? '0'}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                        errorBuilder: (_, _, _) => SizedBox(
                          height: 140,
                          child: Center(
                            child: Icon(
                              Icons.home_work_outlined,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 140,
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
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title ?? 'Room',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${room.province ?? ''}, ${room.state ?? ''}'.trim(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '₹${room.price ?? '0'}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      if (room.landlord?.username != null)
                        Text(
                          'by ${room.landlord!.username}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
