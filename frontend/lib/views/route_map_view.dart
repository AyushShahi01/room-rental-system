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
  bool _isDrivingMode = true;

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
          Obx(() {
            if (_controller.routePoints.isEmpty && !_controller.isRoutingLoading.value && !_isLocating) {
              return const SizedBox.shrink();
            }
            final distanceKm = _controller.routeDistance.value / 1000.0;
            final durationMins = _isDrivingMode
                ? (distanceKm / 25.0 * 60.0).round()
                : (distanceKm / 4.5 * 60.0).round();
            
            String durationText;
            if (durationMins < 1) {
              durationText = '< 1 min';
            } else if (durationMins >= 60) {
              final hrs = durationMins ~/ 60;
              final mins = durationMins % 60;
              durationText = '${hrs} hr ${mins} mins';
            } else {
              durationText = '${durationMins} mins';
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.32,
              minChildSize: 0.16,
              maxChildSize: 0.55,
              snap: true,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Indicator Handle
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                        // Title row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isDrivingMode ? 'Shortest Driving Path' : 'Shortest Walking Path',
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
                                _isDrivingMode
                                    ? Icons.directions_car_filled_rounded
                                    : Icons.directions_walk_rounded,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        // Walk/Drive Tabs selector
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isDrivingMode = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _isDrivingMode
                                        ? colorScheme.primaryContainer
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _isDrivingMode
                                          ? colorScheme.primary
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_car_filled_rounded,
                                        size: 16,
                                        color: _isDrivingMode
                                            ? colorScheme.primary
                                            : Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Drive',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: _isDrivingMode
                                              ? colorScheme.primary
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isDrivingMode = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !_isDrivingMode
                                        ? colorScheme.primaryContainer
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: !_isDrivingMode
                                          ? colorScheme.primary
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_walk_rounded,
                                        size: 16,
                                        color: !_isDrivingMode
                                            ? colorScheme.primary
                                            : Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Walk',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: !_isDrivingMode
                                              ? colorScheme.primary
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats summary
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
                                label: 'Est. Time',
                                value: durationText,
                                icon: Icons.access_time_rounded,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        // Expandable step details
                        Text(
                          'Route Directions',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            _directionStep(
                              icon: Icons.my_location_rounded,
                              iconColor: Colors.blueAccent.shade700,
                              title: 'Starting point',
                              subtitle: 'GPS Location or tapped coordinate',
                            ),
                            _directionDivider(),
                            _directionStep(
                              icon: _isDrivingMode
                                  ? Icons.directions_car_filled_rounded
                                  : Icons.directions_walk_rounded,
                              iconColor: colorScheme.primary,
                              title: _isDrivingMode
                                  ? 'Drive along route'
                                  : 'Walk along path',
                              subtitle: 'Distance: ${distanceKm.toStringAsFixed(2)} km (${_controller.nodeCount.value} road nodes)',
                            ),
                            _directionDivider(),
                            _directionStep(
                              icon: Icons.home_work_rounded,
                              iconColor: Colors.red.shade700,
                              title: widget.roomTitle,
                              subtitle: 'Destination arrived',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.white.withOpacity(0.92),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.1),
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

  Widget _directionStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _directionDivider() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 15),
        height: 16,
        width: 2,
        color: Colors.grey.shade300,
      ),
    );
  }
}
