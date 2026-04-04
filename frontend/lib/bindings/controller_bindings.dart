import 'package:get/get.dart';
import 'package:room_rental_system/controllers/auth_controller.dart';
import 'package:room_rental_system/controllers/home_controller.dart';
import 'package:room_rental_system/controllers/nav_controller.dart';
import 'package:room_rental_system/controllers/splash_controller.dart';
import 'package:room_rental_system/controllers/settings_controller.dart';
import 'package:room_rental_system/controllers/notifications_controller.dart';

class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<NavController>(NavController(), permanent: true);
    Get.put<SplashController>(SplashController(), permanent: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<NotificationsController>(NotificationsController(), permanent: true);
  }
}
