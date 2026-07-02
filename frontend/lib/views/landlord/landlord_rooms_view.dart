import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/room_controller.dart';
import '../../models/room/room_detail_model.dart' as room_detail;
import '../../models/room/room_model.dart';
import '../room/room_detail_view.dart';
import '../room/room_form_view.dart';
import '../room/room_images_view.dart';

class LandlordRoomsView extends StatefulWidget {
  const LandlordRoomsView({super.key});

  @override
  State<LandlordRoomsView> createState() => _LandlordRoomsViewState();
}

class _LandlordRoomsViewState extends State<LandlordRoomsView> {
  final RoomController _roomController = Get.put(RoomController());

  @override
  void initState() {
    super.initState();
    _roomController.loadMyRooms();
  }

  Future<void> _createRoom(Map<String, dynamic> data) async {
    await _roomController.createRoom(data);
  }

  Future<void> _updateRoom(int id, Map<String, dynamic> data) async {
    await _roomController.updateRoom(id, data);
  }

  Future<void> _deleteRoom(int id) async {
    await _roomController.deleteRoom(id);
  }

  Future<void> _toggleAvailability(int id) async {
    await _roomController.toggleAvailability(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'My Rooms',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () => Get.to(
              () => RoomFormView(
                isEditing: false,
                onSubmit: (data) => _createRoom(data),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _roomController.loadMyRooms,
        child: Obx(() {
          if (_roomController.isMyRoomsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final _rooms = _roomController.myRooms;
          if (_rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.meeting_room_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No rooms added yet.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _rooms.length,
            itemBuilder: (context, index) {
              final room = _rooms[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: room.images.isNotEmpty && room.images.first.image != null && room.images.first.image!.isNotEmpty
                          ? Image.network(
                              '${room.images.first.image!}?roomId=${room.id}',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fallbackImage(),
                            )
                          : _fallbackImage(),
                    ),
                    title: Text(
                      room.title ?? 'Untitled Room',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          '${room.province ?? ''}, ${room.state ?? ''} • ₹${room.price ?? '0'}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          room.isAvailable == true
                              ? 'Available'
                              : 'Not available',
                          style: TextStyle(
                            color: room.isAvailable == true
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            await Get.to(
                              () => RoomFormView(
                                isEditing: true,
                                initialRoom: room_detail.RoomDetailModel(
                                  id: room.id,
                                  images: const [],
                                  title: room.title,
                                  description: room.description,
                                  price: room.price?.toString(),
                                  province: room.province,
                                  state: room.state,
                                  wardNumber: room.wardNumber,
                                  furnishedStatus: room.furnishedStatus,
                                  areaSqft: room.areaSqft is int
                                      ? room.areaSqft as int
                                      : int.tryParse(
                                          room.areaSqft?.toString() ?? '0',
                                        ),
                                  securityDeposit: room.securityDeposit
                                      ?.toString(),
                                  maintenanceCharges: room.maintenanceCharges
                                      ?.toString(),
                                  hasWifi: room.hasWifi,
                                  hasAc: room.hasAc,
                                  hasAttachedBathroom:
                                      room.hasAttachedBathroom,
                                  parkingAvailable: room.parkingAvailable,
                                  foodAvailable: room.foodAvailable,
                                  genderPreference: room.genderPreference,
                                  waterSupplyAvailable:
                                      room.waterSupplyAvailable,
                                  wasteCollectionAvailable:
                                      room.wasteCollectionAvailable,
                                  isAvailable: room.isAvailable,
                                  latitude: room.latitude,
                                  longitude: room.longitude,
                                  createdAt: room.createdAt,
                                  updatedAt: room.updatedAt,
                                  landlord: room.landlord,
                                ),
                                onSubmit: (data) =>
                                    _updateRoom(room.id ?? 0, data),
                              ),
                            );
                            break;
                          case 'images':
                            await Get.to(
                              () => RoomImagesView(roomId: room.id ?? 0),
                            );
                            break;
                          case 'toggle':
                            await _toggleAvailability(room.id ?? 0);
                            break;
                          case 'delete':
                            await _deleteRoom(room.id ?? 0);
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'images', child: Text('Images')),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text('Toggle Availability'),
                        ),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    onTap: () =>
                        Get.to(() => RoomDetailView(roomId: room.id ?? 0)),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.indigo.shade50,
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 24,
          color: Colors.indigo.shade700,
        ),
      ),
    );
  }
}
