import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tenant_dashboard_controller.dart';
import '../models/room/room_model.dart';
import 'room/room_detail_view.dart';

class SearchpageView extends StatelessWidget {
  const SearchpageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TenantDashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'Search Rooms',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.performSearch,
                  decoration: InputDecoration(
                    hintText: 'Search room by name ',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Obx(() {
                      if (controller.searchQuery.value.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.performSearch('');
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Obx(() {
                  if (controller.isSearching.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.searchQuery.value.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search for rooms to rent',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No properties found matching "${controller.searchQuery.value}"',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.searchResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final room = controller.searchResults[index] as Result;
                      return SearchRoomCard(
                        room: room,
                        onTap: () =>
                            Get.to(() => RoomDetailView(roomId: room.id ?? 0)),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchRoomCard extends StatelessWidget {
  final Result room;
  final VoidCallback onTap;

  const SearchRoomCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = room.images.isNotEmpty ? room.images.first.image : null;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: SizedBox(
                width: 110,
                height: 110,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                          child: Icon(
                            Icons.home_work_outlined,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        child: Icon(
                          Icons.home_work_outlined,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title ?? 'Room',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
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
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${room.province ?? ''}, ${room.state ?? ''}'
                                .trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs. ${room.price ?? '0'}/mo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        if (room.genderPreference != null &&
                            room.genderPreference!.isNotEmpty &&
                            room.genderPreference!.toLowerCase() != 'any')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              room.genderPreference!.toUpperCase(),
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
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
}
