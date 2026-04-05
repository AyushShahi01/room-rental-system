import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPreviewWidget extends StatelessWidget {
  const MapPreviewWidget({super.key});

  static const List<Map<String, dynamic>> _nepalLocations = [
    {'name': 'Kathmandu', 'lat': 27.7172, 'lng': 85.3240},
    {'name': 'Pokhara', 'lat': 28.2096, 'lng': 83.9856},
    {'name': 'Lalitpur', 'lat': 27.6644, 'lng': 85.3188},
    {'name': 'Bhaktapur', 'lat': 27.6710, 'lng': 85.4298},
    {'name': 'Biratnagar', 'lat': 26.4525, 'lng': 87.2718},
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(28.1, 84.0),
                initialZoom: 6.5,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.roomrental.app',
                ),
                MarkerLayer(
                  markers: _nepalLocations.map((loc) {
                    return Marker(
                      point: LatLng(loc['lat'] as double, loc['lng'] as double),
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: loc['name'] as String,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 36,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 6,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Nepal — 12 nearby rooms',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
