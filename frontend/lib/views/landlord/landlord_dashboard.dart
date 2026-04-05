import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import 'home_view.dart';
import 'add_property_view.dart';
import 'manage_requests_view.dart';
import 'tenants_view.dart';
import 'profile_view.dart';

class LandlordDashboardScreen extends StatelessWidget {
  const LandlordDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DashboardController());

    final screens = [
      const HomeView(),
      const AddPropertyView(),
      const ManageRequestsView(),
      const TenantsView(),
      const ProfileView(showAppBar: false),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Obx(
        () => IndexedStack(index: ctrl.selectedIndex.value, children: screens),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: ctrl.selectedIndex.value,
          onTap: ctrl.changeTab,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 10,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_home_work),
              label: 'Add Room',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Requests',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Tenants'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
