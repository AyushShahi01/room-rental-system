import '../auth_model/user_model.dart';

class MessageChatModel {
  final int? id;
  final UserModel? sender;
  final UserModel? receiver;
  final String content;
  final bool isRead;
  final int? bookingId;
  final DateTime? createdAt;

  MessageChatModel({
    this.id,
    this.sender,
    this.receiver,
    required this.content,
    this.isRead = false,
    this.bookingId,
    this.createdAt,
  });

  factory MessageChatModel.fromJson(Map<String, dynamic> json) {
    return MessageChatModel(
      id: json['id'] as int?,
      sender: json['sender'] == null
          ? null
          : UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      receiver: json['receiver'] == null
          ? null
          : UserModel.fromJson(json['receiver'] as Map<String, dynamic>),
      content: json['content']?.toString() ?? '',
      isRead: json['is_read'] as bool? ?? false,
      bookingId: json['booking_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'is_read': isRead,
      'booking_id': bookingId,
    };
  }
}
