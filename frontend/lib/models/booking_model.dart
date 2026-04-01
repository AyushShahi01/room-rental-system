import 'room_model.dart';
import 'package:get/get.dart';

class BookingModel {
  final String id;
  final RoomModel? room;
  final String moveInDate;
  final String duration;
  final String note;
  
  // Added user fields for landlord manage request
  final String userName;
  final String userPhone;
  final String userAddress;
  
  // Make status observable so UI updates instantly when approved/rejected
  final RxString status;

  BookingModel({
    this.id = '',
    this.room,
    this.moveInDate = '',
    this.duration = '',
    this.note = '',
    this.userName = 'Unknown User',
    this.userPhone = 'N/A',
    this.userAddress = 'N/A',
    String status = 'Pending',
  }) : status = status.obs;
}
