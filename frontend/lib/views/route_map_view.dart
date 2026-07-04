import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/map_controller.dart' as app_map;
import '../utils/location_helper.dart';

class RouteMapView extends StatefulWidget {
  const RouteMapView({
    super.key,
    required this.roomLat,
    required this.roomLng,
    required this.roomTitle,
  });

  final double roomLat;
  final double roomLng;
  final String roomTitle;

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  final app_map.AppMapController _controller = Get.put(app_map.AppMapController());
  final MapController _mapController = MapController();

  // Snapped central Kathmandu coordinate as default fallback starting point
  LatLng _currentLocation = const LatLng(27.7042, 85.3082);
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLocating = true;
      });

      final gpsLocation = await LocationHelper.getCurrentLocation();
      if (gpsLocation != null) {
        if (mounted) {
          setState(() {
            _currentLocation = gpsLocation;
          });
        }
      } else {
        Get.snackbar(
          'Location Service',
          'Could not retrieve GPS location. Using default starting point.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
      }

      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }

      await _controller.fetchRoute(
        originLat: _currentLocation.latitude,
        originLng: _currentLocation.longitude,
        destLat: widget.roomLat,
        destLng: widget.roomLng,
      );

      if (_controller.routePoints.isNotEmpty && mounted) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(_controller.routePoints.toList()),
            padding: const EdgeInsets.only(
              left: 40.0,
              right: 40.0,
              top: 40.0,
              bottom: 260.0, // extra padding at bottom to avoid overlapping with details card
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.clearRoute();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final destLatLng = LatLng(widget.roomLat, widget.roomLng);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Directions to ${widget.roomTitle}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          Obx(() {
            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: destLatLng,
                initialZoom: 14.0,
                onTap: (tapPosition, point) async {
                  setState(() {
                    _currentLocation = point;
                  });
                  await _controller.fetchRoute(
                    originLat: _currentLocation.latitude,
                    originLng: _currentLocation.longitude,
                    destLat: widget.roomLat,
                    destLng: widget.roomLng,
                  );
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.roomrental.app',
                ),
                if (_controller.routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _controller.routePoints.toList(),
                        color: Colors.blueAccent.shade700,
                        strokeWidth: 5.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
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
                    Marker(
                      point: destLatLng,
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.home_work_rounded,
                        size: 40,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          Obx(() {
            if (_controller.isRoutingLoading.value || _isLocating) {
              return Container(
                color: Colors.black12,
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
              if (_controller.routePoints.isEmpty && !_controller.isRoutingLoading.value && !_isLocating) {
                return const SizedBox.shrink();
              }
              final distanceKm = _controller.routeDistance.value / 1000.0;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shortest Driving Path',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Powered by Bidirectional Dijkstra',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.directions_car_filled_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _statRow(
                              context,
                              label: 'Distance',
                              value: '${distanceKm.toStringAsFixed(2)} km',
                              icon: Icons.alt_route_rounded,
                            ),
                          ),
                          Expanded(
                            child: _statRow(
                              context,
                              label: 'Path Nodes',
                              value: '${_controller.nodeCount.value}',
                              icon: Icons.hub_outlined,
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
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.white.withValues(alpha: 0.92),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_rounded, color: Colors.blueAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap anywhere on the map to pick your starting location.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
