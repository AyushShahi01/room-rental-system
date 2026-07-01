import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/room_service.dart';

class RoomImagesView extends StatefulWidget {
  const RoomImagesView({super.key, required this.roomId});

  final int roomId;

  @override
  State<RoomImagesView> createState() => _RoomImagesViewState();
}

class _RoomImagesViewState extends State<RoomImagesView> {
  final RoomService _roomService = RoomService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  List<dynamic> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final response = await _roomService.getRoomImages(widget.roomId);
      if (mounted) setState(() => _images = response.results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load images: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      await _roomService.uploadRoomImage(widget.roomId, File(picked.path));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
        _loadImages();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
          ? const Center(child: Text('No images uploaded yet.'))
          : GridView.builder(
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
                      ? Image.network(url, fit: BoxFit.cover)
                      : const SizedBox.shrink(),
                );
              },
            ),
    );
  }
}
