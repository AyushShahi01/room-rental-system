import 'room_model.dart';

class BookingModel {
  final String id;
  final RoomModel? room;
  final String moveInDate;
  final String duration;
  final String note;
  final String status;

  BookingModel({
    this.id = '',
    this.room,
    this.moveInDate = '',
    this.duration = '',
    this.note = '',
    this.status = '',
  });
}
