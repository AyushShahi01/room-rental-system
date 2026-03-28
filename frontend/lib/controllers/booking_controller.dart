import 'package:get/get.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';

class BookingController extends GetxController {
  // Reactive list of bookings
  var bookings = <BookingModel>[].obs;

  void addBooking(RoomModel room) {
    final newBooking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      room: room,
      moveInDate: '2024-01-01', // Dummy data
      duration: '6 Months', // Dummy data
      status: 'Pending',
    );
    bookings.add(newBooking);
  }
}
