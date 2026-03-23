import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/controllers/nav_controller.dart';
import 'package:room_rental_system/routes/app_routes.dart';
import 'package:room_rental_system/views/booking_view.dart';
import 'package:room_rental_system/views/explore_view.dart';
import 'package:room_rental_system/views/home_content_view.dart';
import 'package:room_rental_system/views/message_view.dart';
import 'package:room_rental_system/views/profile_view.dart';


const _pageTitles = ['Home', 'Explore', 'Booking', 'Message', 'Profile'];

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(NavController());

    final pages = [
      const HomeContentView(),
      const ExploreView(),
      const BookingView(),
      const MessageView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
        
          if (navController.selectedIndex.value == 0) {
            return const SizedBox.shrink();
          }

          return AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            title: Text(
              _pageTitles[navController.selectedIndex.value],
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // Settings icon (visible on Profile tab)
              if (navController.selectedIndex.value == 4)
                IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: Colors.black87),
                  tooltip: 'Settings',
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                ),
              // Notification bell — always visible on other tabs
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.black87),
                tooltip: 'Notifications',
                onPressed: () => Get.toNamed(AppRoutes.notifications),
              ),
            ],
          );
        }),
      ),
      body: Obx(() => IndexedStack(
            index: navController.selectedIndex.value,
            children: pages,
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: navController.selectedIndex.value,
            onTap: navController.onItemTapped,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: 'Booking'),
              BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Message'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          )),
    );
  }
}

