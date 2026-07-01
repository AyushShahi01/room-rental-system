import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/booking_controller.dart';
import '../../models/booking/bookinglist_model.dart';
import '../../models/room/room_detail_model.dart' as room_detail;
import '../../services/room_service.dart';
import '../booking_view.dart';

class TenantBookingsView extends StatefulWidget {
  const TenantBookingsView({super.key});

  @override
  State<TenantBookingsView> createState() => _TenantBookingsViewState();
}

class _TenantBookingsViewState extends State<TenantBookingsView> {
  final BookingController controller = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    controller.loadTenantBookings();
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
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (_) => _CreateBookingSheet(controller: controller),
            ),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return _StatePlaceholder(
            icon: Icons.wifi_off_outlined,
            title: 'Could not load bookings',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Try again',
            onAction: () => controller.loadTenantBookings(),
          );
        }

        if (controller.tenantBookings.isEmpty) {
          return _StatePlaceholder(
            icon: Icons.calendar_month_outlined,
            title: 'No bookings yet',
            subtitle: 'Create your first booking request and track it here.',
            actionLabel: 'Create booking',
            onAction: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (_) => _CreateBookingSheet(controller: controller),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadTenantBookings(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.tenantBookings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final booking = controller.tenantBookings[index];
              return _BookingCard(
                booking: booking,
                onTap: () => Get.to(
                  () => BookingDetailsView(bookingId: booking.id ?? 0),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _CreateBookingSheet extends StatelessWidget {
  const _CreateBookingSheet({required this.controller});
  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Create booking',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Submit a booking request for a room by entering its room ID.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.roomIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Room ID',
              prefixIcon: const Icon(Icons.meeting_room_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isSubmitting.value) {
              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: null,
                  icon: const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  label: const Text('Submitting...'),
                ),
              );
            }

            return SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await controller.createBooking();
                  if (!context.mounted) return;
                  if (controller.successMessage.isNotEmpty) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Submit request'),
              ),
            );
          }),
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: colorScheme.error),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

class _BookingCard extends StatefulWidget {
  const _BookingCard({required this.booking, required this.onTap});
  final Result booking;
  final VoidCallback onTap;

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  final RoomService _roomService = RoomService();
  room_detail.RoomDetailModel? _room;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    final roomId = widget.booking.room;
    if (roomId == null) {
      return;
    }

    try {
      final result = await _roomService.getRoom(roomId);
      if (mounted) {
        setState(() => _room = result);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(widget.booking.status ?? '', colorScheme);
    final roomTitle = _room?.title ?? 'Room ${widget.booking.room ?? ''}';
    final landlordLabel = _displayName(_room?.landlord);
    final imageUrl = _extractImageUrl(_room?.images);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallbackImage(),
                        )
                      : _fallbackImage(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            roomTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
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
                            (widget.booking.status ?? 'pending').toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            landlordLabel,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _statusLabel(widget.booking.status ?? ''),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _room?.price ?? 'Price available soon',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: Colors.indigo.shade50,
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 36,
          color: Colors.indigo.shade700,
        ),
      ),
    );
  }

  String _displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Landlord';
    }
    final trimmed = value.trim();
    if (RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(trimmed) ||
        RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Landlord';
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

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved booking';
      case 'rejected':
        return 'Rejected booking';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled booking';
      default:
        return 'Pending review';
    }
  }

  Color _statusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 42,
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
            const SizedBox(height: 20),
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
