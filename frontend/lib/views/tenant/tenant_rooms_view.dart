import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/room/room_model.dart';
import '../../services/room_service.dart';
import '../room/room_detail_view.dart';

class TenantRoomsView extends StatefulWidget {
  const TenantRoomsView({super.key});

  @override
  State<TenantRoomsView> createState() => _TenantRoomsViewState();
}

class _TenantRoomsViewState extends State<TenantRoomsView> {
  final RoomService _roomService = RoomService();
  bool _isLoading = true;
  bool _showRecommendations = false;
  List<Result> _rooms = [];
  List<Result> _recommended = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);

    List<Result> rooms = [];
    List<Result> recommendations = [];
    String? roomsError;
    String? recommendationsError;

    try {
      final response = await _roomService.getRooms();
      rooms = response.results;
    } catch (e) {
      roomsError = e.toString();
    }

    try {
      final response = await _roomService.getRecommendations({});
      recommendations = response.results;
    } catch (e) {
      recommendationsError = e.toString();
    }

    if (mounted) {
      setState(() {
        _rooms = rooms;
        _recommended = recommendations;
      });

      if (roomsError != null && recommendationsError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load rooms: $roomsError')),
        );
      } else if (roomsError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load all rooms: $roomsError')),
        );
      } else if (recommendationsError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load recommendations: $recommendationsError'),
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'Home Listings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRooms,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_recommended.isNotEmpty) ...[
                      Text(
                        'Recommended Rooms',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recommended.length,
                          itemBuilder: (context, index) {
                            final room = _recommended[index];
                            return _RoomCard(
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
                      'All Rooms',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_rooms.isEmpty)
                      const Center(child: Text('No rooms available right now.'))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _rooms.length,
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
              ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    Icons.home_work_outlined,
                    color: Colors.indigo.shade700,
                    size: 52,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              room.title ?? 'Room',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${room.province ?? ''}, ${room.state ?? ''}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              '₹${room.price ?? '0'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
