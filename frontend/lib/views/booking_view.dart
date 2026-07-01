import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/booking_controller.dart';
import '../models/room/room_detail_model.dart' as room_detail;
import '../services/room_service.dart';

class BookingDetailsView extends StatefulWidget {
  const BookingDetailsView({super.key, required this.bookingId});

  final int bookingId;

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  final BookingController controller = Get.put(BookingController());
  final RoomService _roomService = RoomService();
  room_detail.RoomDetailModel? _room;

  @override
  void initState() {
    super.initState();
    controller.loadBookingDetails(widget.bookingId);
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    try {
      final room = await _roomService.getRoom(
        controller.selectedBooking.value?.room ?? 0,
      );
      if (mounted) {
        setState(() => _room = room);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty &&
            controller.selectedBooking.value == null) {
          return _StatePlaceholder(
            icon: Icons.error_outline_rounded,
            title: 'Booking unavailable',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Try again',
            onAction: () => controller.loadBookingDetails(widget.bookingId),
          );
        }

        final booking = controller.selectedBooking.value;
        if (booking == null) {
          return _StatePlaceholder(
            icon: Icons.info_outline_rounded,
            title: 'No booking selected',
            subtitle: 'Select or create a booking to see more details.',
            actionLabel: 'Go back',
            onAction: () => Get.back(),
          );
        }

        final status = booking.status?.toLowerCase() ?? 'pending';
        final statusColor = _statusColor(status, colorScheme);
        final roomImage = _extractImageUrl(_room?.images);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (roomImage.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Image.network(roomImage, fit: BoxFit.cover),
                          ),
                        )
                      else
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.home_work_outlined,
                              size: 38,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _room?.title ??
                                  'Booking for room ${booking.room ?? ''}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Tenant',
                        value: _displayName(booking.tenant),
                      ),
                      _InfoRow(
                        icon: Icons.person_pin_circle_outlined,
                        label: 'Landlord',
                        value: _displayName(_room?.landlord),
                      ),
                      _InfoRow(
                        icon: Icons.attach_money_rounded,
                        label: 'Price',
                        value: _room?.price ?? 'Available soon',
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: '${_room?.province ?? ''}, ${_room?.state ?? ''}'
                            .trim(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.isSubmitting.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () =>
                          controller.approveBooking(widget.bookingId),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Approve'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          controller.rejectBooking(widget.bookingId),
                      icon: const Icon(Icons.block_outlined),
                      label: const Text('Reject'),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          controller.cancelBooking(widget.bookingId),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel'),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.successMessage.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      controller.successMessage.value,
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        );
      }),
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

  String _extractImageUrl(List<room_detail.Image>? images) {
    if (images == null || images.isEmpty) return '';
    for (final image in images) {
      if (image.image != null && image.image!.isNotEmpty) return image.image!;
    }
    return '';
  }

  Color _statusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'cancelled':
      case 'canceled':
        return Colors.blueGrey.shade700;
      default:
        return colorScheme.primary;
    }
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
      padding: const EdgeInsets.only(bottom: 10),
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

class _StatePlaceholder extends StatelessWidget {
  const _StatePlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 38,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
