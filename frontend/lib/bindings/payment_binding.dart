import 'package:get/get.dart';
import 'package:room_rental_system/controllers/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PaymentController>(PaymentController(), permanent: false);
  }
}
