import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/booking_controller.dart';
import '../../models/room/room_detail_model.dart' as room_detail;
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
  room_detail.RoomDetailModel? _room;
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

  Future<void> _bookNow() async {
    final bookingController = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : Get.put(BookingController());
    bookingController.roomIdController.text = widget.roomId.toString();
    await bookingController.createBooking();
    if (!mounted) return;
    if (bookingController.successMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking request submitted successfully.'),
        ),
      );
    } else if (bookingController.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingController.errorMessage.value)),
      );
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
          'Room Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
                  if (_room!.images.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: Image.network(
                          _room!.images.first.image ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallbackImage(),
                        ),
                      ),
                    )
                  else
                    _fallbackImage(height: 220),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _room!.title ?? 'Untitled Room',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _room!.description ?? 'No description available.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _pill(
                                '₹${_room!.price ?? "0"}',
                                Icons.attach_money_rounded,
                                colorScheme,
                              ),
                              _pill(
                                _room!.isAvailable == true
                                    ? 'Available'
                                    : 'Booked',
                                _room!.isAvailable == true
                                    ? Icons.check_circle
                                    : Icons.block,
                                colorScheme,
                              ),
                              _pill(
                                '${_room!.province ?? ''}, ${_room!.state ?? ''}'
                                    .trim(),
                                Icons.location_on_outlined,
                                colorScheme,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.person_outline,
                            label: 'Landlord',
                            value: _displayName(_room!.landlord),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amenities',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
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
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _bookNow,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Book Now'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Get.to(() => RoomImagesView(roomId: widget.roomId)),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('View Images'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _fallbackImage({double height = 140}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 42,
          color: Colors.indigo.shade700,
        ),
      ),
    );
  }

  String _displayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not available';
    final trimmed = value.trim();
    if (RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(trimmed) ||
        RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Shared host';
    }
    return trimmed;
  }

  Widget _pill(String label, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
