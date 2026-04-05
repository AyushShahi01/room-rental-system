import 'package:get/get.dart';
import 'package:room_rental_system/controllers/booking_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BookingController>(BookingController(), permanent: false);
  }
}
