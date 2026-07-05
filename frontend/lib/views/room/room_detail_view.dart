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
import '../tenant/booking_success_view.dart';
import '../../models/room/room_detail_model.dart' as detail_model;

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

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _roomController.loadRoomDetail(widget.roomId);
    
    final role = Get.find<AuthController>().currentUser.value?.role?.toLowerCase();
    if (role == 'landlord') {
      _bookingController.loadIncomingBookings(showLoading: false);
    } else if (role == 'tenant') {
      _bookingController.loadTenantBookings(showLoading: false);
    }
  }

  Future<void> _bookNow() async {
    final room = _roomController.currentRoomDetail.value;
    if (room == null) return;
    _showAgreementConfirmation(context, room);
  }

  void _showAgreementConfirmation(BuildContext context, detail_model.RoomDetailModel room) {
    final RxBool isAgreed = false.obs;
    final colorScheme = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.gavel_rounded, color: colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Lease Agreement Terms',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Please review and agree to the landlord\'s terms and rules before booking this room:',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAgreementRow(Icons.monetization_on_outlined, 'Monthly Rent', 'Rs. ${room.price ?? "0"} / month', colorScheme),
                    _buildAgreementRow(
                      Icons.security_rounded,
                      'Security Deposit',
                      room.securityDeposit != null && room.securityDeposit!.isNotEmpty
                          ? 'Rs. ${room.securityDeposit}'
                          : 'N/A',
                      colorScheme,
                    ),
                    _buildAgreementRow(
                      Icons.build_circle_outlined,
                      'Maintenance Fee',
                      room.maintenanceCharges != null && room.maintenanceCharges!.isNotEmpty
                          ? 'Rs. ${room.maintenanceCharges}'
                          : 'Rs. 0',
                      colorScheme,
                    ),
                    const Divider(height: 24),
                    if (room.agreementPolicy != null && room.agreementPolicy!.trim().isNotEmpty) ...[
                      const Text(
                        'Rental Agreement Policy & Rules:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          room.agreementPolicy!,
                          style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: isAgreed.value,
                onChanged: (val) => isAgreed.value = val ?? false,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I agree to the landlord\'s terms and house rules.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => FilledButton(
                      onPressed: isAgreed.value
                          ? () async {
                              Get.back(); // close sheet
                              await _submitBooking(room);
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Agree & Book'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _submitBooking(detail_model.RoomDetailModel room) async {
    try {
      _bookingController.roomIdController.text = room.id.toString();
      await _bookingController.createBooking();
      
      final booking = _bookingController.selectedBooking.value;
      if (booking != null) {
        Get.to(() => BookingSuccessView(booking: booking));
      }
    } catch (e) {
      debugPrint('Error booking room: $e');
    }
  }

  Widget _buildAgreementRow(IconData icon, String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specCard({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _amenityChip(String label, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage({double height = 220}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
      ),
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 48,
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (_roomController.isRoomDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final _room = _roomController.currentRoomDetail.value;
        if (_room == null) {
          return const Center(child: Text('Room not found'));
        }

        final isOwnRoom = _room.landlord?.id == Get.find<AuthController>().currentUser.value?.id;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Swipable Image Carousel
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: _room.images.isNotEmpty
                        ? PageView.builder(
                            itemCount: _room.images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.network(
                                _room.images[index].image ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _fallbackImage(height: 300),
                              );
                            },
                          )
                        : _fallbackImage(height: 300),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  if (_room.images.length > 1)
                    Positioned(
                      bottom: 32,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_room.images.length, (index) {
                          final isSelected = _currentImageIndex == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: isSelected ? 24 : 8,
                            decoration: BoxDecoration(
                              color: isSelected ? colorScheme.primary : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),

              // Details Panel
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header title + price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _room.title ?? 'Untitled Room',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, size: 16, color: colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_room.province ?? ''}, ${_room.state ?? ''}'.trim(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rs. ${_room.price ?? "0"}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: colorScheme.primary,
                                      fontSize: 22,
                                    ),
                              ),
                              Text(
                                '/ month',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Availability indicator
                      Obx(() {
                        final hasBooking = _bookingController.tenantBookings.any(
                          (b) => b.roomId == widget.roomId && (b.status?.toLowerCase() == 'pending' || b.status?.toLowerCase() == 'approved')
                        );
                        final isBooked = _room.isAvailable == false || hasBooking;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isBooked ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isBooked ? Colors.red.shade200 : Colors.green.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isBooked ? Icons.block : Icons.check_circle,
                                size: 16,
                                color: isBooked ? Colors.red.shade800 : Colors.green.shade800,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isBooked ? 'Already Booked' : 'Available for Booking',
                                style: TextStyle(
                                  color: isBooked ? Colors.red.shade800 : Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Room Specs Grid
                      Text(
                        'Room Overview',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _specCard(
                              icon: Icons.chair_outlined,
                              label: 'Furnishing',
                              value: _room.furnishedStatus == true ? 'Furnished' : 'Unfurnished',
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(width: 12),
                            _specCard(
                              icon: Icons.square_foot_rounded,
                              label: 'Area',
                              value: _room.areaSqft != null ? '${_room.areaSqft} sqft' : 'N/A',
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(width: 12),
                            _specCard(
                              icon: Icons.security_rounded,
                              label: 'Deposit',
                              value: _room.securityDeposit != null ? 'Rs. ${_room.securityDeposit}' : 'N/A',
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(width: 12),
                            _specCard(
                              icon: Icons.build_circle_outlined,
                              label: 'Maintenance',
                              value: _room.maintenanceCharges != null ? 'Rs. ${_room.maintenanceCharges}' : 'Rs. 0',
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Amenities chips
                      Text(
                        'Amenities',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_room.hasWifi == true) _amenityChip('Wi-Fi', Icons.wifi, colorScheme),
                          if (_room.hasAc == true) _amenityChip('AC', Icons.ac_unit, colorScheme),
                          if (_room.hasAttachedBathroom == true) _amenityChip('Attached Bath', Icons.bathtub_outlined, colorScheme),
                          if (_room.parkingAvailable == true) _amenityChip('Parking', Icons.local_parking, colorScheme),
                          if (_room.foodAvailable == true) _amenityChip('Food', Icons.restaurant, colorScheme),
                          if (_room.waterSupplyAvailable == true) _amenityChip('Water Supply', Icons.water_drop_outlined, colorScheme),
                          if (_room.wasteCollectionAvailable == true) _amenityChip('Waste Collection', Icons.delete_outline, colorScheme),
                          if (_room.furnishedStatus == true) _amenityChip('Furnished', Icons.chair, colorScheme),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'About this Room',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _room.description ?? 'No description available.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Hosted by details card (only for tenants)
                      if (!isOwnRoom) ...[
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hosted By',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: colorScheme.primaryContainer,
                                      foregroundColor: colorScheme.onPrimaryContainer,
                                      radius: 24,
                                      child: Text(
                                        _displayName(_room.landlord).isNotEmpty
                                            ? _displayName(_room.landlord)[0].toUpperCase()
                                            : 'L',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _displayName(_room.landlord),
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.onSurface,
                                                ),
                                          ),
                                          Text(
                                            'Host Landlord',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
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
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      backgroundColor: Colors.white,
                                      foregroundColor: colorScheme.primary,
                                      elevation: 0,
                                      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Location details card
                      Text(
                        'Location & Directions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.map_outlined, color: colorScheme.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_room.state ?? ""}, ${_room.province ?? ""}',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onSurface,
                                              ),
                                        ),
                                        Text(
                                          'Ward Number: ${_room.wardNumber ?? "N/A"}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (_room.latitude != null && _room.longitude != null &&
                                  double.tryParse(_room.latitude.toString()) != 0.0 &&
                                  double.tryParse(_room.longitude.toString()) != 0.0) ...[
                                const SizedBox(height: 16),
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
                                    icon: const Icon(Icons.directions_outlined),
                                    label: const Text('Get Directions (Map)'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      backgroundColor: colorScheme.secondaryContainer,
                                      foregroundColor: colorScheme.onSecondaryContainer,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Administration / booking actions card
                      if (isOwnRoom) ...[
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
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
                        Obx(() {
                          final activeBooking = _bookingController.incomingBookings.firstWhereOrNull(
                            (b) => b.roomId == widget.roomId && b.status?.toLowerCase() == 'approved',
                          );
                          if (activeBooking == null) return const SizedBox.shrink();
                          return Card(
                            elevation: 0,
                            color: Colors.green.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.green.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
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
                                          color: Colors.green.shade700,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'ACTIVE',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    icon: Icons.person_outline,
                                    label: 'Name',
                                    value: activeBooking.tenantUser != null
                                        ? '${activeBooking.tenantUser!.firstName ?? ""} ${activeBooking.tenantUser!.lastName ?? ""}'.trim()
                                        : (activeBooking.tenantName ?? 'Tenant'),
                                  ),
                                  _InfoRow(
                                    icon: Icons.location_city_outlined,
                                    label: 'Address',
                                    value: activeBooking.tenantUser?.city != null
                                        ? '${activeBooking.tenantUser!.city}, ${activeBooking.tenantUser!.province ?? ""}'.trim()
                                        : 'N/A',
                                  ),
                                  _InfoRow(
                                    icon: Icons.email_outlined,
                                    label: 'Email',
                                    value: activeBooking.tenantUser?.email ?? 'N/A',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ] else ...[
                        // Rent policy & agreement card (tenants)
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
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
                        const SizedBox(height: 24),
                        // Book Now button
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() {
                            final hasBooking = _bookingController.tenantBookings.any(
                              (b) => b.roomId == widget.roomId && (b.status?.toLowerCase() == 'pending' || b.status?.toLowerCase() == 'approved')
                            );
                            final isBooked = _room.isAvailable == false || hasBooking;

                            return FilledButton.icon(
                              onPressed: isBooked ? null : _bookNow,
                              icon: Icon(isBooked ? Icons.block : Icons.calendar_month_outlined),
                              label: Text(isBooked ? 'Already Booked' : 'Book Now'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: isBooked ? colorScheme.outlineVariant.withValues(alpha: 0.3) : colorScheme.primary,
                                foregroundColor: isBooked ? colorScheme.onSurfaceVariant : colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
