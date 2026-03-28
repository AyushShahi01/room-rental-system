import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class RoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<RoomController>(RoomController(), permanent: false);
  }
}
