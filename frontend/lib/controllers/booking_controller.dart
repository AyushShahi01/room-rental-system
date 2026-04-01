import 'package:get/get.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';
import 'auth_controller.dart'; // Import auth controller to fetch user data

class BookingController extends GetxController {
  // Reactive list of bookings (mocking a database)
  var bookings = <BookingModel>[].obs;

  void addBooking(RoomModel room) {
    // Get user info from AuthController
    final authCtrl = Get.find<AuthController>();

    final newBooking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      room: room,
      moveInDate: '2024-01-01', // Dummy data
      duration: '6 Months', // Dummy data
      userName: authCtrl.userName.value,
      userPhone: authCtrl.userPhone.value.isNotEmpty ? authCtrl.userPhone.value : 'N/A',
      userAddress: authCtrl.userAddress.value.isNotEmpty ? authCtrl.userAddress.value : 'N/A',
      status: 'Pending',
    );
    bookings.add(newBooking);
  }

  // Method for Landlord to approve
  void approveRequest(String id) {
    final index = bookings.indexWhere((req) => req.id == id);
    if (index != -1) {
      bookings[index].status.value = 'Approved';
      // force update if needed, but Rx properties inside models are reactive
    }
  }

  // Method for Landlord to reject
  void rejectRequest(String id) {
    final index = bookings.indexWhere((req) => req.id == id);
    if (index != -1) {
      bookings[index].status.value = 'Rejected';
    }
  }
}
