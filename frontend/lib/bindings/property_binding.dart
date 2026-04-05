import 'package:get/get.dart';
import 'package:room_rental_system/controllers/property_controller.dart';

class PropertyBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<PropertyController>(PropertyController(), permanent: false);
  }
}
