import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../models/room/room_location_model.dart';
import '../utils/dio_connection.dart';

class MapService {
  final Dio _dio = DioConnection.dio;

  /// Fetches all rooms that have GPS coordinates set.
  Future<List<RoomLocationModel>> getRoomLocations() async {
    final response = await _dio.get('maps/rooms/');
    if (response.data is List) {
      final list = response.data as List;
      return list
          .map((json) => RoomLocationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Computes the shortest driving path using Bidirectional Dijkstra on the backend.
  /// Returns a Map containing:
  /// - 'path': List<LatLng> representing the route polyline coordinates
  /// - 'distance_meters': double representing the total distance in meters
  Future<Map<String, dynamic>> getShortestRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final response = await _dio.post(
      'maps/route/shortest/',
      data: {
        'origin_lat': originLat,
        'origin_lng': originLng,
        'destination_lat': destLat,
        'destination_lng': destLng,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final pathRaw = data['path'] as List? ?? [];
    
    final List<LatLng> pathPoints = pathRaw.map((coord) {
      final map = coord as Map<String, dynamic>;
      final lat = double.tryParse(map['lat']?.toString() ?? '0.0') ?? 0.0;
      final lng = double.tryParse(map['lng']?.toString() ?? '0.0') ?? 0.0;
      return LatLng(lat, lng);
    }).toList();

    return {
      'path': pathPoints,
      'distance_meters': double.tryParse(data['distance_meters']?.toString() ?? '0.0') ?? 0.0,
      'node_count': data['node_count'] as int? ?? 0,
    };
  }
}
