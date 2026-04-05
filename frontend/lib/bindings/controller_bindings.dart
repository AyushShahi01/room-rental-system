import 'package:get/get.dart';
import 'package:room_rental_system/controllers/auth_controller.dart';
import 'package:room_rental_system/controllers/home_controller.dart';
import 'package:room_rental_system/controllers/booking_controller.dart';
import 'package:room_rental_system/controllers/dashboard_controller.dart';
import 'package:room_rental_system/controllers/payment_controller.dart';
import 'package:room_rental_system/controllers/property_controller.dart';
import 'package:room_rental_system/controllers/settings_controller.dart';
import 'package:room_rental_system/controllers/notifications_controller.dart';
import 'package:room_rental_system/controllers/maintenance_controller.dart';

class ControllerBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<PropertyController>(PropertyController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<DashboardController>(DashboardController(), permanent: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<NotificationsController>(
      NotificationsController(),
      permanent: true,
    );
    Get.put<BookingController>(BookingController(), permanent: true);
    Get.put<PaymentController>(PaymentController(), permanent: true);
    Get.put<MaintenanceController>(MaintenanceController(), permanent: true);
  }
}
