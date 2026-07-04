import '../auth_model/user_model.dart';

class RentRecordModel {
  final int id;
  final UserModel tenant;
  final RentRecordRoomModel room;
  final String amount;
  final String amountPaid;
  final int billingMonth;
  final int billingYear;
  final String dueDate;
  final String? paymentDate;
  final String status;
  final String remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  RentRecordModel({
    required this.id,
    required this.tenant,
    required this.room,
    required this.amount,
    required this.amountPaid,
    required this.billingMonth,
    required this.billingYear,
    required this.dueDate,
    this.paymentDate,
    required this.status,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentRecordModel.fromJson(Map<String, dynamic> json) {
    return RentRecordModel(
      id: json['id'] as int,
      tenant: UserModel.fromJson(json['tenant'] as Map<String, dynamic>),
      room: RentRecordRoomModel.fromJson(json['room'] as Map<String, dynamic>),
      amount: json['amount']?.toString() ?? '0.00',
      amountPaid: json['amount_paid']?.toString() ?? '0.00',
      billingMonth: json['billing_month'] as int,
      billingYear: json['billing_year'] as int,
      dueDate: json['due_date'] as String,
      paymentDate: json['payment_date'] as String?,
      status: json['status']?.toString() ?? 'unpaid',
      remarks: json['remarks']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class RentRecordRoomModel {
  final int id;
  final String title;
  final String price;
  final List<String> images;

  RentRecordRoomModel({
    required this.id,
    required this.title,
    required this.price,
    required this.images,
  });

  factory RentRecordRoomModel.fromJson(Map<String, dynamic> json) {
    var imgsList = json['images'] as List<dynamic>? ?? [];
    List<String> parsedImgs = [];
    for (var img in imgsList) {
      if (img is Map && img['image'] != null) {
        parsedImgs.add(img['image'].toString());
      } else if (img is String) {
        parsedImgs.add(img);
      }
    }
    return RentRecordRoomModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? 'Unknown Room',
      price: json['price']?.toString() ?? '0.00',
      images: parsedImgs,
    );
  }
}
