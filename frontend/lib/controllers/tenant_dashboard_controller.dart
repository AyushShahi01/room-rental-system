import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/room/room_model.dart';
import '../services/room_service.dart';

class TenantDashboardController extends GetxController {
  final RoomService _roomService = RoomService();

  final RxInt selectedIndex = 0.obs;

  final Rxn<RoomModel> dashboardData = Rxn<RoomModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Search parameters needed by tenant views
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isSearchMode = false.obs;
  final RxList<dynamic> searchResults = <dynamic>[].obs;

  // Property list parameters needed by tenant views
  final RxList<dynamic> allProperties = <dynamic>[].obs;
  final RxList<dynamic> featuredProperties = <dynamic>[].obs;
  final RxList<dynamic> nearbyProperties = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _roomService.getRooms();
      dashboardData.value = data;
      allProperties.assignAll(data.results);
      featuredProperties.assignAll(data.results.take(3).toList());
    } catch (e) {
      errorMessage.value = 'Failed to load rooms: ${e.toString()}';
      debugPrint('Error loading tenant dashboard rooms: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void performSearch(String query) {
    searchQuery.value = query.trim();
    if (searchQuery.value.isEmpty) {
      isSearchMode.value = false;
      searchResults.clear();
    } else {
      isSearchMode.value = true;
      searchResults.clear();
    }
  }
}
