import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/room_controller.dart';

class RoomImagesView extends StatefulWidget {
  const RoomImagesView({super.key, required this.roomId});

  final int roomId;

  @override
  State<RoomImagesView> createState() => _RoomImagesViewState();
}

class _RoomImagesViewState extends State<RoomImagesView> {
  final RoomController _roomController = Get.put(RoomController());
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _roomController.loadRoomDetail(widget.roomId);
  }

  Future<void> _pickAndUpload() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    await _roomController.uploadRoomImage(widget.roomId, File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Room Images'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndUpload,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add Image'),
      ),
      body: Obx(() {
        if (_roomController.isRoomDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final _room = _roomController.currentRoomDetail.value;
        if (_room == null || _room.id != widget.roomId) {
          return const Center(child: Text('Room not found'));
        }
        final _images = _room.images;
        if (_images.isEmpty) {
          return const Center(child: Text('No images uploaded yet.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            final image = _images[index];
            final url = image.image?.toString() ?? '';
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: url.startsWith('http')
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400, size: 30),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          },
        );
      }),
    );
  }
}
