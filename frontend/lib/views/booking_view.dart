import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/controllers/auth_controller.dart';

import '../controllers/booking_controller.dart';
import '../models/room/room_detail_model.dart' as room_detail;

class BookingDetailsView extends StatefulWidget {
  const BookingDetailsView({super.key, required this.bookingId});

  final int bookingId;

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  final BookingController controller = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadBookingDetails(widget.bookingId);
    });
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

        final room = controller.selectedBookingRoom.value;
        final status = booking.status?.toLowerCase() ?? 'pending';
        final statusColor = _statusColor(status, colorScheme);
        final roomImage = _extractImageUrl(room?.images);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (roomImage.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Image.network(
                      roomImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallbackImage(),
                    ),
                  ),
                )
              else
                _fallbackImage(),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              booking.roomTitle ?? room?.title ?? 'Booking details',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                      if (room?.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          room!.description!,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _pill(
                            '₹${booking.roomPrice ?? room?.price ?? "0"}',
                            Icons.attach_money_rounded,
                            colorScheme,
                          ),
                          if (room != null)
                            _pill(
                              room.isAvailable == true
                                  ? 'Available'
                                  : 'Booked',
                              room.isAvailable == true
                                  ? Icons.check_circle
                                  : Icons.block,
                              colorScheme,
                            ),
                          _pill(
                            _formatLocation(
                              booking.roomProvince ?? room?.province,
                              booking.roomState ?? room?.state,
                            ) ?? 'Location unavailable',
                            Icons.location_on_outlined,
                            colorScheme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Tenant',
                        value: controller.tenantName.value.isNotEmpty
                            ? controller.tenantName.value
                            : booking.tenantName,
                      ),
                      _InfoRow(
                        icon: Icons.person_pin_circle_outlined,
                        label: 'Landlord',
                        value: controller.landlordName.value.isNotEmpty
                            ? controller.landlordName.value
                            : booking.landlordName,
                      ),
                    ],
                  ),
                ),
              ),
              if (room != null) ...[
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
                            if (room.hasWifi == true) _chip('Wi-Fi'),
                            if (room.hasAc == true) _chip('AC'),
                            if (room.hasAttachedBathroom == true)
                              _chip('Attached Bathroom'),
                            if (room.parkingAvailable == true)
                              _chip('Parking'),
                            if (room.foodAvailable == true) _chip('Food'),
                            if (room.waterSupplyAvailable == true)
                              _chip('Water'),
                            if (room.wasteCollectionAvailable == true)
                              _chip('Waste Collection'),
                            if (room.furnishedStatus == true)
                              _chip('Furnished'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Obx(() {
                if (controller.isSubmitting.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final role = Get.find<AuthController>().selectedRole.value.toLowerCase();
                final isLandlord = role == 'landlord' || role == 'admin';

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (isLandlord) ...[
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
                    ] else ...[
                      TextButton.icon(
                        onPressed: () =>
                            controller.cancelBooking(widget.bookingId),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                      ),
                    ],
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

  String? _formatLocation(String? province, String? state) {
    final parts = <String>[];
    if (province != null && province.trim().isNotEmpty) parts.add(province.trim());
    if (state != null && state.trim().isNotEmpty) parts.add(state.trim());
    return parts.isEmpty ? null : parts.join(', ');
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

  Widget _fallbackImage({double height = 220}) {
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
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) return const SizedBox.shrink();
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
            child: Text(value!, style: Theme.of(context).textTheme.bodyMedium),
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
