import 'package:get/get.dart';
import 'package:room_rental_system/controllers/auth_controller.dart';
import 'package:room_rental_system/controllers/nav_controller.dart';
import 'package:room_rental_system/controllers/splash_controller.dart';
import 'package:room_rental_system/controllers/settings_controller.dart';
import 'package:room_rental_system/controllers/tenant_dashboard_controller.dart';
import 'package:room_rental_system/controllers/landlord_dashboard_controller.dart';
import 'package:room_rental_system/controllers/message_controller.dart';
import 'package:room_rental_system/controllers/notification_controller.dart';

class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.lazyPut<TenantDashboardController>(
      TenantDashboardController.new,
      fenix: true,
    );
    Get.lazyPut<LandlordDashboardController>(
      LandlordDashboardController.new,
      fenix: true,
    );
    Get.put<NavController>(NavController(), permanent: true);
    Get.put<SplashController>(SplashController(), permanent: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.lazyPut<MessageController>(MessageController.new, fenix: true);
    Get.lazyPut<NotificationController>(NotificationController.new, fenix: true);
  }
}
