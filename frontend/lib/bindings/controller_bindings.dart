import 'package:get/get.dart';
import 'package:room_rental_system/core/network/api_client.dart';
import 'package:room_rental_system/features/auth/controllers/auth_controller.dart';
import 'package:room_rental_system/features/home/controllers/nav_controller.dart';
import 'package:room_rental_system/features/splash/controllers/splash_controller.dart';
import 'package:room_rental_system/features/settings/controllers/settings_controller.dart';
import 'package:room_rental_system/features/message/controllers/message_controller.dart';

class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    // Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<NavController>(NavController(), permanent: true);
    Get.put<SplashController>(SplashController(), permanent: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<MessageController>(MessageController(), permanent: true);
  }
}
