import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/booking_controller.dart';
import '../../models/booking/bookinglist_model.dart';
import '../../models/room/room_detail_model.dart' as room_detail;
import '../../models/auth_model/user_model.dart';
import '../../services/room_service.dart';
import '../booking_view.dart';
import '../message/chat_detail_view.dart';

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
  @override
  Widget build(BuildContext context) {

    Color statusColor;
    Color statusBgColor;
    final statusStr = (widget.booking.status ?? 'pending').toLowerCase();
    if (statusStr == 'approved') {
      statusColor = const Color(0xFF2E7D32);
      statusBgColor = const Color(0xFFE8F5E9);
    } else if (statusStr == 'rejected') {
      statusColor = const Color(0xFFC62828);
      statusBgColor = const Color(0xFFFFEBEE);
    } else if (statusStr == 'cancelled' || statusStr == 'canceled') {
      statusColor = const Color(0xFF616161);
      statusBgColor = const Color(0xFFF5F5F5);
    } else {
      statusColor = const Color(0xFFB78103);
      statusBgColor = const Color(0xFFFFF8E1);
    }

    final roomTitle = widget.booking.roomTitle ?? 'Room #${widget.booking.roomId ?? ''}';
    final imageUrl = widget.booking.roomImages.isNotEmpty ? widget.booking.roomImages.first : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 90,
                      height: 90,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                roomTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusStr.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.booking.tenantName ?? 'Tenant name unavailable',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 15,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.booking.createdAt != null
                                    ? widget.booking.createdAt!.toLocal().toString().split(' ')[0]
                                    : 'Date not available',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.payments_outlined,
                              size: 15,
                              color: Colors.indigo.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.booking.roomPrice != null && widget.booking.roomPrice!.isNotEmpty
                                  ? 'Rs. ${widget.booking.roomPrice}'
                                  : 'Price available soon',
                              style: TextStyle(
                                color: Colors.indigo.shade800,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.booking.status != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.grey.shade100, height: 1),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: widget.booking.tenantId == null
                            ? null
                            : () {
                                final tenantUser = UserModel(
                                  id: widget.booking.tenantId,
                                  username: widget.booking.tenantName,
                                  email: '',
                                  firstName: widget.booking.tenantName,
                                  lastName: '',
                                  role: 'tenant',
                                  tenantId: widget.booking.tenantId,
                                  landlordId: null,
                                  province: null,
                                  district: null,
                                  city: null,
                                  ward: null,
                                );
                                Get.to(() => ChatDetailView(
                                      partner: tenantUser,
                                      bookingId: widget.booking.id,
                                    ));
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 16,
                                color: Colors.indigo.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Chat',
                                style: TextStyle(
                                  color: Colors.indigo.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.booking.status?.toLowerCase() == 'pending') ...[
                      Material(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: widget.booking.id == null
                              ? null
                              : () async {
                                  await Get.find<BookingController>().rejectBooking(
                                    widget.booking.id!,
                                  );
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.block_outlined,
                                  size: 16,
                                  color: Colors.red.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Reject',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: widget.booking.id == null
                              ? null
                              : () async {
                                  await Get.find<BookingController>().showApproveDialog(
                                    context,
                                    widget.booking.id!,
                                  );
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Approve',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (widget.booking.status?.toLowerCase() == 'approved') ...[
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: widget.booking.id == null
                              ? null
                              : () async {
                                  await Get.find<BookingController>().cancelBooking(
                                    widget.booking.id!,
                                  );
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  size: 16,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
