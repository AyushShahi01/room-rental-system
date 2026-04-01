import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Reactive variable to track the current tab index
  var selectedIndex = 0.obs;

  // Function to change the tab when a user taps a bottom nav icon
  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
