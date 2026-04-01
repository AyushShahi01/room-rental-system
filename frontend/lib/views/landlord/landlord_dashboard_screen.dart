import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/landlord_dashboard_controller.dart';
import '../home_content_view.dart';
import 'landlord_requests_view.dart';
import '../profile_view.dart';

class LandlordDashboardScreen extends StatelessWidget {
  const LandlordDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(LandlordDashboardController());

    final screens = [
      const HomeContentView(), // Landlord home view (reusing tenant home content for now, or can be a specific view)
      const LandlordRequestsView(),
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
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Requests'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          )),
    );
  }
}
