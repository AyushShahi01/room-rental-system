import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/map_controller.dart' as app_map;
import '../models/room/room_location_model.dart';
import 'room/room_detail_view.dart';
import 'route_map_view.dart';
import '../utils/location_helper.dart';

class ExploreMapView extends StatefulWidget {
  const ExploreMapView({super.key});

  @override
  State<ExploreMapView> createState() => _ExploreMapViewState();
}

class _ExploreMapViewState extends State<ExploreMapView> {
  final app_map.AppMapController _controller = Get.put(app_map.AppMapController());
  final MapController _mapController = MapController();

  static final LatLng _kathmanduCenter = LatLng(27.7042, 85.3082);
  LatLng? _currentUserLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller.loadRoomLocations();

      // Automatically request and center on user location on startup
      setState(() {
        _isLocating = true;
      });
      final loc = await LocationHelper.getCurrentLocation();
      setState(() {
        _isLocating = false;
      });

      if (loc != null && mounted) {
        setState(() {
          _currentUserLocation = loc;
        });
        _mapController.move(loc, 13.5);
      }
    });
  }

  @override
  void dispose() {
    _controller.selectedRoom.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rooms Map',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          Obx(() {
            final markers = _controller.roomLocations.map((room) {
              final isSelected = _controller.selectedRoom.value?.id == room.id;
              return Marker(
                point: LatLng(room.latitude, room.longitude),
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () async {
                    _controller.selectedRoom.value = room;
                    
                    // Zoom into the room's surrounding map area
                    _mapController.move(LatLng(room.latitude, room.longitude), 15.5);
                    
                    // Instantly calculate and highlight the shortest path to this room
                    if (_currentUserLocation != null) {
                      await _controller.fetchRoute(
                        originLat: _currentUserLocation!.latitude,
                        originLng: _currentUserLocation!.longitude,
                        destLat: room.latitude,
                        destLng: room.longitude,
                      );
                    }
                  },
                  child: Icon(
                    Icons.location_on_rounded,
                    size: isSelected ? 48 : 36,
                    color: isSelected ? Colors.red.shade800 : Colors.blue.shade600,
                  ),
                ),
              );
            }).toList();

            if (_currentUserLocation != null) {
              markers.add(
                Marker(
                  point: _currentUserLocation!,
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.shade700.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent.shade700, width: 2),
                    ),
                    child: Icon(
                      Icons.my_location_rounded,
                      size: 24,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                ),
              );
            }

            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _kathmanduCenter,
                initialZoom: 13.0,
                onTap: (_, __) {
                  // Deselect and clear route when tapping the map background
                  _controller.selectedRoom.value = null;
                  _controller.clearRoute();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.roomrental.app',
                ),
                Obx(() {
                  if (_controller.routePoints.isNotEmpty) {
                    return PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _controller.routePoints.toList(),
                          color: Colors.blueAccent.shade700.withValues(alpha: 0.8),
                          strokeWidth: 5.0,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
                MarkerLayer(markers: markers),
              ],
            );
          }),
          Obx(() {
            if (_controller.isLoading.value) {
              return Container(
                color: Colors.white70,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Obx(() {
              final selected = _controller.selectedRoom.value;
              if (selected == null) return const SizedBox.shrink();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selected.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${selected.province}, ${selected.state} (Ward ${selected.wardNumber})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'NPR ${selected.price}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      // Progress bar showing when the route is loading
                      if (_controller.isRoutingLoading.value)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: LinearProgressIndicator(),
                        ),
                      // Show driving distance directly inside details card
                      if (_controller.routePoints.isNotEmpty && !_controller.isRoutingLoading.value)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.directions_car_filled_rounded, size: 18, color: Colors.blueAccent),
                              const SizedBox(width: 8),
                              Text(
                                'Distance: ${(_controller.routeDistance.value / 1000.0).toStringAsFixed(2)} km',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => Get.to(() => RoomDetailView(roomId: selected.id)),
                              icon: const Icon(Icons.info_outline_rounded),
                              label: const Text('View Room Details'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _isLocating = true;
          });
          final loc = await LocationHelper.getCurrentLocation();
          setState(() {
            _isLocating = false;
          });
          if (loc != null) {
            setState(() {
              _currentUserLocation = loc;
            });
            _mapController.move(loc, 14.5);
          } else {
            Get.snackbar(
              'Location Service',
              'Could not retrieve your current GPS location.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black87,
              colorText: Colors.white,
            );
          }
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: _isLocating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.my_location_rounded),
      ),
    );
  }
}
