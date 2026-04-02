import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import 'home_content_view.dart';
import 'explore_view.dart';
import 'booking_view.dart';
import 'maintenance_request_view.dart';
import 'profile_view.dart';

class TenantDashboardScreen extends StatelessWidget {
  const TenantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController ctrl = Get.put(DashboardController());

    final screens = [
      const HomeContentView(),
      const ExploreView(),
      const BookingView(),
      const MaintenanceRequestView(),
      const ProfileView(showAppBar: false),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Obx(() => IndexedStack(
        index: ctrl.selectedIndex.value,
        children: screens,
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: ctrl.selectedIndex.value,
        onTap: ctrl.changeTab,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 10,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), label: 'Maintenance'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      )),
    );
  }
}
