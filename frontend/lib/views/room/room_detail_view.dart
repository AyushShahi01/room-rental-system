import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/booking_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/room/landlord_model.dart';
import '../../models/auth_model/user_model.dart';
import '../message/chat_detail_view.dart';
import 'room_images_view.dart';
import 'room_form_view.dart';
import '../route_map_view.dart';
import '../agreement_view.dart';
import '../payment_history_view.dart';

class RoomDetailView extends StatefulWidget {
  const RoomDetailView({super.key, required this.roomId});

  final int roomId;

  @override
  State<RoomDetailView> createState() => _RoomDetailViewState();
}

class _RoomDetailViewState extends State<RoomDetailView> {
  final RoomController _roomController = Get.put(RoomController());
  final BookingController _bookingController = Get.isRegistered<BookingController>()
      ? Get.find<BookingController>()
      : Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    _roomController.loadRoomDetail(widget.roomId);
    
    // Automatically load incoming bookings for landlord to inspect active bookings/tenants
    if (Get.find<AuthController>().currentUser.value?.role?.toLowerCase() == 'landlord') {
      _bookingController.loadIncomingBookings(showLoading: false);
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
      body: Obx(() {
        if (_roomController.isRoomDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final _room = _roomController.currentRoomDetail.value;
        if (_room == null) {
          return const Center(child: Text('Room not found'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_room.images.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Image.network(
                      _room.images.first.image ?? '',
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
                        _room.title ?? 'Untitled Room',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _room.description ?? 'No description available.',
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
                            '₹${_room.price ?? "0"}',
                            Icons.attach_money_rounded,
                            colorScheme,
                          ),
                          _pill(
                            _room.isAvailable == true
                                ? 'Available'
                                : 'Booked',
                            _room.isAvailable == true
                                ? Icons.check_circle
                                : Icons.block,
                            colorScheme,
                          ),
                          _pill(
                            '${_room.province ?? ''}, ${_room.state ?? ''}'
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
                        value: _displayName(_room.landlord),
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
                          if (_room.hasWifi == true) _chip('Wi-Fi'),
                          if (_room.hasAc == true) _chip('AC'),
                          if (_room.hasAttachedBathroom == true)
                            _chip('Attached Bathroom'),
                          if (_room.parkingAvailable == true)
                            _chip('Parking'),
                          if (_room.foodAvailable == true) _chip('Food'),
                          if (_room.waterSupplyAvailable == true)
                            _chip('Water'),
                          if (_room.wasteCollectionAvailable == true)
                            _chip('Waste Collection'),
                          if (_room.furnishedStatus == true)
                            _chip('Furnished'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final isOwnRoom = _room.landlord?.id == Get.find<AuthController>().currentUser.value?.id;
                
                if (isOwnRoom) {
                  final activeBooking = _bookingController.incomingBookings.firstWhereOrNull(
                    (b) => b.roomId == widget.roomId && b.status?.toLowerCase() == 'approved',
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                'Room Administration',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await Get.to(
                                          () => RoomFormView(
                                            isEditing: true,
                                            initialRoom: _room,
                                            onSubmit: (data) => _roomController.updateRoom(_room.id ?? 0, data),
                                          ),
                                        );
                                        _roomController.loadRoomDetail(widget.roomId);
                                      },
                                      icon: const Icon(Icons.edit_outlined),
                                      label: const Text('Edit Details'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => Get.to(() => RoomImagesView(roomId: _room.id ?? 0)),
                                      icon: const Icon(Icons.photo_library_outlined),
                                      label: const Text('Manage Images'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (activeBooking != null)
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tenant Details (Rented)',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Active Rent',
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _InfoRow(
                                  icon: Icons.person_outline,
                                  label: 'Name',
                                  value: activeBooking.tenantName ?? 'N/A',
                                ),
                                if (activeBooking.tenantUser?.email != null)
                                  _InfoRow(
                                    icon: Icons.email_outlined,
                                    label: 'Email',
                                    value: activeBooking.tenantUser!.email!,
                                  ),
                                if (activeBooking.tenantUser?.city != null)
                                  _InfoRow(
                                    icon: Icons.location_city_outlined,
                                    label: 'Address',
                                    value: '${activeBooking.tenantUser?.city}, ${activeBooking.tenantUser?.province} (Ward ${activeBooking.tenantUser?.ward})',
                                  ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Get.to(() => AgreementDetailsView(
                                                bookingId: activeBooking.id ?? 0,
                                                roomName: _room.title ?? 'Room',
                                                roomImage: _room.images.isNotEmpty ? _room.images.first.image ?? '' : '',
                                                landlordName: activeBooking.landlordName ?? 'Landlord',
                                                tenantName: activeBooking.tenantName ?? 'Tenant',
                                              ));
                                        },
                                        icon: const Icon(Icons.description_outlined),
                                        label: const Text('Agreement'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.primaryContainer,
                                          foregroundColor: colorScheme.onPrimaryContainer,
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Get.to(() => const PaymentHistoryView());
                                        },
                                        icon: const Icon(Icons.receipt_long_outlined),
                                        label: const Text('Payment Logs'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      final tenantUserModel = UserModel(
                                        id: activeBooking.tenantUser?.id ?? activeBooking.tenantId,
                                        username: activeBooking.tenantName ?? 'Tenant',
                                        email: activeBooking.tenantUser?.email,
                                        firstName: activeBooking.tenantUser?.firstName,
                                        lastName: activeBooking.tenantUser?.lastName,
                                        role: 'tenant',
                                        tenantId: activeBooking.tenantId,
                                        landlordId: null,
                                        province: activeBooking.tenantUser?.province,
                                        district: activeBooking.tenantUser?.district,
                                        city: activeBooking.tenantUser?.city,
                                        ward: activeBooking.tenantUser?.ward,
                                      );
                                      Get.to(() => ChatDetailView(partner: tenantUserModel));
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                                    label: const Text('Chat with Tenant'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
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
                                  'Rental Policy & Agreement',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _room.agreementPolicy != null && _room.agreementPolicy!.trim().isNotEmpty
                                      ? _room.agreementPolicy!
                                      : 'No agreement policy/lease terms set for this room yet.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      if (_room.latitude != null && _room.longitude != null &&
                          double.tryParse(_room.latitude.toString()) != 0.0 &&
                          double.tryParse(_room.longitude.toString()) != 0.0) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final lat = double.tryParse(_room.latitude.toString()) ?? 0.0;
                              final lng = double.tryParse(_room.longitude.toString()) ?? 0.0;
                              Get.to(() => RouteMapView(
                                    roomLat: lat,
                                    roomLng: lng,
                                    roomTitle: _room.title ?? 'Room',
                                  ));
                            },
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Get Directions (Map)'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: colorScheme.secondaryContainer,
                              foregroundColor: colorScheme.onSecondaryContainer,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final landlordUser = UserModel(
                              id: _room.landlord?.id,
                              username: _room.landlord?.username,
                              email: _room.landlord?.email,
                              firstName: _room.landlord?.firstName,
                              lastName: _room.landlord?.lastName,
                              role: _room.landlord?.role ?? 'landlord',
                              tenantId: null,
                              landlordId: _room.landlord?.landlordId,
                              province: _room.landlord?.province,
                              district: _room.landlord?.district,
                              city: _room.landlord?.city,
                              ward: _room.landlord?.ward,
                            );
                            Get.to(() => ChatDetailView(partner: landlordUser));
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: const Text('Message Landlord'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.white,
                            foregroundColor: colorScheme.primary,
                            elevation: 0,
                            side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
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
                  );
                }
              }),
            ],
          ),
        );
      }),
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

  String _displayName(LandlordModel? landlord) {
    if (landlord == null) return 'Not available';
    if (landlord.username != null && landlord.username!.isNotEmpty) {
      return landlord.username!;
    }
    if (landlord.firstName != null && landlord.firstName!.isNotEmpty) {
      return '${landlord.firstName} ${landlord.lastName ?? ''}'.trim();
    }
    return 'Shared host';
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
