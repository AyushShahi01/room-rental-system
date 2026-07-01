import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/room/room_detail_model.dart';
import '../../services/room_service.dart';
import 'room_images_view.dart';

class RoomDetailView extends StatefulWidget {
  const RoomDetailView({super.key, required this.roomId});

  final int roomId;

  @override
  State<RoomDetailView> createState() => _RoomDetailViewState();
}

class _RoomDetailViewState extends State<RoomDetailView> {
  final RoomService _roomService = RoomService();
  RoomDetailModel? _room;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    try {
      final room = await _roomService.getRoom(widget.roomId);
      if (mounted) setState(() => _room = room);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load room: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Room Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _room == null
          ? const Center(child: Text('Room not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _room!.title ?? 'Untitled Room',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _room!.description ?? 'No description',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _pill(
                              '₹${_room!.price ?? "0"}',
                              Icons.attach_money,
                            ),
                            const SizedBox(width: 8),
                            _pill(
                              _room!.isAvailable == true
                                  ? 'Available'
                                  : 'Booked',
                              _room!.isAvailable == true
                                  ? Icons.check_circle
                                  : Icons.block,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_room!.province ?? ''}, ${_room!.state ?? ''} • Ward ${_room!.wardNumber ?? ''}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amenities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (_room!.hasWifi == true) _chip('Wi-Fi'),
                            if (_room!.hasAc == true) _chip('AC'),
                            if (_room!.hasAttachedBathroom == true)
                              _chip('Attached Bathroom'),
                            if (_room!.parkingAvailable == true)
                              _chip('Parking'),
                            if (_room!.foodAvailable == true) _chip('Food'),
                            if (_room!.waterSupplyAvailable == true)
                              _chip('Water'),
                            if (_room!.wasteCollectionAvailable == true)
                              _chip('Waste Collection'),
                            if (_room!.furnishedStatus == true)
                              _chip('Furnished'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Get.to(() => RoomImagesView(roomId: widget.roomId)),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('View Images'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _pill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.indigo.shade700),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
