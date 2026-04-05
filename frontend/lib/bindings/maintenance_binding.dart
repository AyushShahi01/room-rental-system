import 'package:get/get.dart';
import 'package:room_rental_system/controllers/maintenance_controller.dart';

class MaintenanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MaintenanceController>(MaintenanceController(), permanent: false);
  }
}
