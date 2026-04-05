import 'package:get/get.dart';

class BookingModel {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final int price;
  final String moveInDate;
  final String duration;
  final String note;

  final String userName;
  final String userPhone;
  final String userAddress;

  final RxString status;
  final RxBool isPaid;

  BookingModel({
    required this.id,
    required this.propertyId,
    this.propertyTitle = 'Unknown Room',
    this.price = 0,
    this.moveInDate = '',
    this.duration = '',
    this.note = '',
    this.userName = 'Unknown User',
    this.userPhone = 'N/A',
    this.userAddress = 'N/A',
    String status = 'Pending',
    bool isPaid = false,
  }) : status = status.obs,
       isPaid = isPaid.obs;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      propertyId: json['propertyId'] ?? '',
      propertyTitle: json['propertyTitle'] ?? 'Unknown Room',
      price: json['price'] ?? 0,
      moveInDate: json['moveInDate'] ?? '',
      duration: json['duration'] ?? '',
      note: json['note'] ?? '',
      userName: json['userName'] ?? 'Unknown User',
      userPhone: json['userPhone'] ?? 'N/A',
      userAddress: json['userAddress'] ?? 'N/A',
      status: json['status'] ?? 'Pending',
      isPaid: json['isPaid'] ?? false,
    );
  }
}
