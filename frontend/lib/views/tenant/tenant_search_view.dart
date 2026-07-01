import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tenant_dashboard_controller.dart';

class TenantSearchView extends StatelessWidget {
  const TenantSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TenantDashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Search Rooms', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.performSearch,
                  decoration: InputDecoration(
                    hintText: 'Search city, state or room name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Obx(() {
                      if (controller.searchQuery.value.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.performSearch('');
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Search for rooms to rent',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No properties found matching "${controller.searchQuery.value}"',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(child: Text('Search Results'));
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
