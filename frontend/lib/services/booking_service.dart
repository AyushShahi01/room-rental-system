import 'package:dio/dio.dart';

import '../models/booking/booking_model.dart';
import '../models/booking/bookinglist_model.dart';
import '../models/booking/commonresponsebooking_model.dart';
import '../utils/dio_connection.dart';

class BookingService {
  final Dio _dio = DioConnection.dio;

  Future<BookingListModel> getBookings() async {
    final response = await _dio.get('bookings/');
    return BookingListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BookingModel> createBooking(Map<String, dynamic> data) async {
    final response = await _dio.post('bookings/', data: data);
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BookingModel> getBooking(int id) async {
    final response = await _dio.get('bookings/$id/');
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CommonResponseBookingModel> approveBooking(int id) async {
    final response = await _dio.patch('bookings/$id/approve/');
    return CommonResponseBookingModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<CommonResponseBookingModel> cancelBooking(int id) async {
    final response = await _dio.patch('bookings/$id/cancel/');
    return CommonResponseBookingModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<CommonResponseBookingModel> rejectBooking(int id) async {
    final response = await _dio.patch('bookings/$id/reject/');
    return CommonResponseBookingModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<BookingListModel> getIncomingBookings() async {
    final response = await _dio.get('bookings/incoming/');
    return BookingListModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BookingListModel> getMyBookings() async {
    final response = await _dio.get('bookings/my-bookings/');
    return BookingListModel.fromJson(response.data as Map<String, dynamic>);
  }
}
