import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/booking_controller.dart';
import '../../models/booking/bookinglist_model.dart';
import '../../models/room/room_detail_model.dart' as room_detail;
import '../../services/room_service.dart';
import '../booking_view.dart';

class LandlordBookingsView extends StatefulWidget {
  const LandlordBookingsView({super.key});

  @override
  State<LandlordBookingsView> createState() => _LandlordBookingsViewState();
}

class _LandlordBookingsViewState extends State<LandlordBookingsView> {
  final BookingController controller = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    controller.loadIncomingBookings();
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
          'Incoming Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0.5,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return _StatePlaceholder(
            icon: Icons.wifi_off_outlined,
            title: 'Could not load requests',
            subtitle: controller.errorMessage.value,
            actionLabel: 'Try again',
            onAction: () => controller.loadIncomingBookings(),
          );
        }

        if (controller.incomingBookings.isEmpty) {
          return _StatePlaceholder(
            icon: Icons.inbox_outlined,
            title: 'No booking requests',
            subtitle:
                'Incoming requests will appear here when tenants book a room.',
            actionLabel: 'Refresh',
            onAction: () => controller.loadIncomingBookings(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadIncomingBookings(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.incomingBookings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final booking = controller.incomingBookings[index];
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
    final tenantLabel = _displayName(widget.booking.tenant);
    final imageUrl = _extractImageUrl(_room?.images);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _fallbackImage(),
                            )
                          : _fallbackImage(),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                                (widget.booking.status ?? 'pending')
                                    .toUpperCase(),
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
                                tenantLabel,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: widget.booking.id == null
                        ? null
                        : () async {
                            await Get.find<BookingController>().approveBooking(
                              widget.booking.id!,
                            );
                          },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Approve'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.booking.id == null
                        ? null
                        : () async {
                            await Get.find<BookingController>().rejectBooking(
                              widget.booking.id!,
                            );
                          },
                    icon: const Icon(Icons.block_outlined),
                    label: const Text('Reject'),
                  ),
                  TextButton.icon(
                    onPressed: widget.booking.id == null
                        ? null
                        : () async {
                            await Get.find<BookingController>().cancelBooking(
                              widget.booking.id!,
                            );
                          },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                  ),
                ],
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
          size: 32,
          color: Colors.indigo.shade700,
        ),
      ),
    );
  }

  String _displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tenant';
    }
    final trimmed = value.trim();
    if (RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(trimmed) ||
        RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Tenant';
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
