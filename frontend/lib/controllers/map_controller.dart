import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../models/room/room_location_model.dart';
import '../services/map_service.dart';

class AppMapController extends GetxController {
  final MapService _service = MapService();

  final RxBool isLoading = false.obs;
  final RxBool isRoutingLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // List of rooms with map coordinates
  final RxList<RoomLocationModel> roomLocations = <RoomLocationModel>[].obs;

  // Active route state
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxDouble routeDistance = 0.0.obs;
  final RxInt nodeCount = 0.obs;

  // Selected room on the map
  final Rxn<RoomLocationModel> selectedRoom = Rxn<RoomLocationModel>();

  /// Load all available room coordinates from the backend.
  Future<void> loadRoomLocations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final locations = await _service.getRoomLocations();
      roomLocations.assignAll(locations);
    } catch (e) {
      errorMessage.value = 'Failed to load room locations.';
      debugPrint('[MapController] Error loading locations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculates the shortest route polyline using Bidirectional Dijkstra.
  Future<void> fetchRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      isRoutingLoading.value = true;
      errorMessage.value = '';
      routePoints.clear();
      routeDistance.value = 0.0;
      nodeCount.value = 0;

      debugPrint(
        '[MapController] Routing from ($originLat, $originLng) to ($destLat, $destLng)',
      );
      final routeData = await _service.getShortestRoute(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );

      routePoints.assignAll(routeData['path'] as List<LatLng>);
      routeDistance.value = routeData['distance_meters'] as double;
      nodeCount.value = routeData['node_count'] as int;

      if (routePoints.isEmpty) {
        Get.snackbar(
          'No route',
          'Could not find a road path between coordinates.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch shortest route.';
      debugPrint('[MapController] Error computing route: $e');
      Get.snackbar(
        'Routing Error',
        'Unable to compute shortest path right now.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      isRoutingLoading.value = false;
    }
  }

  /// Clears the current route polyline from the map.
  void clearRoute() {
    routePoints.clear();
    routeDistance.value = 0.0;
    nodeCount.value = 0;
  }
}
