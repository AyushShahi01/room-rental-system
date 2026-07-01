import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/landlord_dashboard_controller.dart';
import '../profile_view.dart';
import 'landlord_dashboard.dart';
import 'landlord_rooms_view.dart';
import 'landlord_bookings_view.dart';
import 'landlord_messages_view.dart';

class LandlordMainView extends StatelessWidget {
  const LandlordMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LandlordDashboardController>();

    final List<Widget> pages = [
      const LandlordDashboard(),
      const LandlordRoomsView(),
      const LandlordBookingsView(),
      const LandlordMessagesView(),
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
          selectedItemColor: Colors.indigo.shade700,
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
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_outlined),
              label: 'Rooms',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
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
