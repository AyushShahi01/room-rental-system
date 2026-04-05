import 'package:dio/dio.dart';
import 'package:room_rental_system/utils/dio_connection.dart';
import 'package:room_rental_system/controllers/storage_controller.dart';
import 'package:room_rental_system/models/booking_model.dart';

class BookingService {
  static Future<Response> createBooking(BookingModel booking) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.post(
      "bookings/",
      data: {
        "property_id": booking.propertyId,
        "move_in_date": booking.moveInDate,
        "duration_months": booking.duration,
        "note": booking.note,
      },
    );
  }

  static Future<Response> fetchBookings() async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.get("bookings/");
  }

  static Future<Response> updateStatus(String bookingId, String status) async {
    var token = StorageController().getToken();
    DioConnection.dio.options.headers['Authorization'] = "Bearer $token";
    return await DioConnection.dio.put(
      "bookings/$bookingId/status/",
      data: {"status": status},
    );
  }
}
