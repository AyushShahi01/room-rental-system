import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tenant_dashboard_controller.dart';
import '../profile_view.dart';
import 'tenant_dashboard.dart';
import 'tenant_rooms_view.dart';
import 'tenant_bookings_view.dart';
import 'tenant_messages_view.dart';

class TenantMainView extends StatelessWidget {
  const TenantMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TenantDashboardController>();

    final List<Widget> pages = [
      const TenantDashboard(),
      const TenantRoomsView(),
      const TenantBookingsView(),
      const TenantMessagesView(),
      const ProfileView(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.onItemTapped,
          selectedItemColor: Colors.blueAccent.shade700,
          unselectedItemColor: Colors.grey.shade500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_work_outlined),
              label: 'Rooms',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
