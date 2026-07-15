import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/controllers/auth_controller.dart';

import '../controllers/booking_controller.dart';
import '../models/booking/booking_model.dart';
import '../models/room/room_detail_model.dart' as room_detail;
import '../models/auth_model/user_model.dart';
import '../models/maintenace/maintenace_list_model.dart' as maintenance_list;
import '../services/maintenance_service.dart';
import 'message/chat_detail_view.dart';
import 'agreement_view.dart';

class BookingDetailsView extends StatefulWidget {
  const BookingDetailsView({super.key, required this.bookingId});

  final int bookingId;

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  final BookingController controller = Get.put(BookingController());
  List<maintenance_list.Result> _maintenanceRequests = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.loadBookingDetails(widget.bookingId);
      await _loadMaintenance();
    });
  }

  Future<void> _loadMaintenance() async {
    try {
      final booking = controller.selectedBooking.value;
      if (booking != null && booking.roomId != null) {
        final res = await MaintenanceService().getMaintenanceByRoom(booking.roomId!);
        setState(() {
          _maintenanceRequests = res.results;
        });
      }
    } catch (e) {
      debugPrint('Error loading maintenance in booking details: $e');
    }
  }

  /// Reload booking details whenever this page is resumed (e.g. after returning
  /// from AgreementDetailsView or PaymentView) so that agreement / payment
  /// status badges update without a full app restart.
  Future<void> _reloadOnReturn() async {
    await controller.loadBookingDetails(widget.bookingId);
    await _loadMaintenance();
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
        final resolvedTenantName = controller.tenantName.value.isNotEmpty
            ? controller.tenantName.value
            : (booking.tenantName ?? 'Tenant');
        final resolvedLandlordName = controller.landlordName.value.isNotEmpty
            ? controller.landlordName.value
            : (booking.landlordName ?? 'Landlord');
        final resolvedRoomTitle =
            booking.roomTitle ?? room?.title ?? 'Booking details';
        final roomImage = _resolveRoomImage(room, booking);

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
                            'Rs. ${booking.roomPrice ?? room?.price ?? "0"}',
                            Icons.payments_outlined,
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
                        value: resolvedTenantName,
                      ),
                      _InfoRow(
                        icon: Icons.person_pin_circle_outlined,
                        label: 'Landlord',
                        value: resolvedLandlordName,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.payment,
                        label: 'Payment Status',
                        value: controller.paymentStatus.value.toUpperCase(),
                        color: _statusColor(controller.paymentStatus.value, colorScheme),
                      ),
                      _InfoRow(
                        icon: Icons.description_outlined,
                        label: 'Agreement Status',
                        value: controller.agreementStatus.value.toUpperCase(),
                      ),
                      if (booking.rentStartDate != null)
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Rent Collection Starts',
                          value: booking.rentStartDate!,
                        ),
                      if (booking.bookedDate != null)
                        _InfoRow(
                          icon: Icons.bookmark_added_outlined,
                          label: 'Booked Date',
                          value: booking.bookedDate!,
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
              _buildMaintenanceSection(colorScheme),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.isSubmitting.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final role = Get.find<AuthController>().selectedRole.value.toLowerCase();
                final isLandlord = role == 'landlord' || role == 'admin';
                final innerHasAgreement = controller.agreementExists.value;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        final partnerUser = UserModel(
                          id: isLandlord ? booking.tenantId : booking.landlordId,
                          username: isLandlord ? booking.tenantName : booking.landlordName,
                          email: '',
                          firstName: isLandlord ? booking.tenantName : booking.landlordName,
                          lastName: '',
                          role: isLandlord ? 'tenant' : 'landlord',
                          tenantId: isLandlord ? booking.tenantId : null,
                          landlordId: isLandlord ? null : booking.landlordId,
                          province: null,
                          district: null,
                          city: null,
                          ward: null,
                        );
                        Get.to(() => ChatDetailView(
                              partner: partnerUser,
                              bookingId: booking.id,
                            ));
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: Text(isLandlord ? 'Chat with Tenant' : 'Chat with Landlord'),
                    ),
                    if (isLandlord) ...[
                      if (status == 'pending') ...[
                        FilledButton.icon(
                          onPressed: () =>
                              controller.showApproveDialog(context, widget.bookingId),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Approve'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              controller.rejectBooking(widget.bookingId),
                          icon: const Icon(Icons.block_outlined),
                          label: const Text('Reject'),
                        ),
                      ],
                      if (status == 'approved' && innerHasAgreement)
                        OutlinedButton.icon(
                          onPressed: () => _openAgreementDetails(
                            bookingId: booking.id ?? widget.bookingId,
                            roomName: resolvedRoomTitle,
                            roomImage: roomImage,
                            landlordName: resolvedLandlordName,
                            tenantName: resolvedTenantName,
                          ),
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('View Agreement'),
                        ),
                    ] else ...[
                      if (status == 'approved' && innerHasAgreement) ...[
                        OutlinedButton.icon(
                          onPressed: () => _openAgreementDetails(
                            bookingId: booking.id ?? widget.bookingId,
                            roomName: resolvedRoomTitle,
                            roomImage: roomImage,
                            landlordName: resolvedLandlordName,
                            tenantName: resolvedTenantName,
                          ),
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('View Agreement'),
                        ),
                      ],
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

  Future<void> _openAgreementDetails({
    required int bookingId,
    required String roomName,
    required String roomImage,
    required String landlordName,
    required String tenantName,
  }) async {
    await Get.to(
      () => AgreementDetailsView(
        bookingId: bookingId,
        roomName: roomName,
        roomImage: roomImage,
        landlordName: landlordName,
        tenantName: tenantName,
      ),
    );
    // Reload booking details so the agreement status (and button label) updates
    // immediately when the user returns from the agreement screen.
    await _reloadOnReturn();
  }

  String _resolveRoomImage(
    room_detail.RoomDetailModel? room,
    BookingModel booking,
  ) {
    if (room != null && room.images.isNotEmpty) {
      final url = _extractImageUrl(room.images);
      if (url.isNotEmpty) return url;
    }
    if (booking.roomImages.isNotEmpty) {
      return booking.roomImages.first;
    }
    return '';
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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 42,
          color: Colors.blueAccent.shade700,
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

  Widget _buildMaintenanceSection(ColorScheme colorScheme) {
    if (_maintenanceRequests.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
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
              'Maintenance Requests',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _maintenanceRequests.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final req = _maintenanceRequests[index];
                final statusStr = (req.status ?? 'pending').toLowerCase();
                
                Color statusColor = Colors.orange;
                if (statusStr == 'resolved') statusColor = Colors.green;
                if (statusStr == 'in_progress') statusColor = Colors.blue;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              req.description ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusStr.toUpperCase().replaceAll('_', ' '),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Requested on: ${req.createdAt?.toLocal().toString().split(' ')[0] ?? ''}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color? color;

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
            child: Text(
              value!, 
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
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
