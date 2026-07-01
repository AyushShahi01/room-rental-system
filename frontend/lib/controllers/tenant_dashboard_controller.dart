import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/auth_model/tenant_dash_model.dart';

class TenantDashboardController extends GetxController {
  final AuthService _authService = AuthService();

  final RxInt selectedIndex = 0.obs;

  final Rxn<TenantDashModel> dashboardData = Rxn<TenantDashModel>();
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
      final data = await _authService.getTenantDashboard();
      dashboardData.value = data;
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard: ${e.toString()}';
      debugPrint('Error loading tenant dashboard: $e');
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
