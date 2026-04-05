import 'package:get/get.dart';
import '../models/booking_model.dart';
import '../models/property_model.dart';
import 'auth_controller.dart';

class BookingController extends GetxController {
  var bookings = <BookingModel>[].obs;

  void addBooking(PropertyModel property) {
    final authCtrl = Get.find<AuthController>();

    final newBooking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      propertyId: property.id,
      propertyTitle: property.title,
      price: property.price,
      moveInDate: '2024-01-01',
      duration: '6 Months',
      userName: authCtrl.userName.value,
      userPhone: authCtrl.userPhone.value.isNotEmpty
          ? authCtrl.userPhone.value
          : 'N/A',
      userAddress: authCtrl.userAddress.value.isNotEmpty
          ? authCtrl.userAddress.value
          : 'N/A',
      status: 'Pending',
      isPaid: false,
    );
    bookings.add(newBooking);
    Get.snackbar("Success", "Booking request sent successfully");
  }

  void approveRequest(String id) {
    final index = bookings.indexWhere((req) => req.id == id);
    if (index != -1) {
      bookings[index].status.value = 'Approved';
    }
  }

  void rejectRequest(String id) {
    final index = bookings.indexWhere((req) => req.id == id);
    if (index != -1) {
      bookings[index].status.value = 'Rejected';
    }
  }

  void submitPayment(String id) {
    final index = bookings.indexWhere((req) => req.id == id);
    if (index != -1) {
      bookings[index].isPaid.value = true;
      bookings.refresh();
    }
  }
}
