import 'package:room_rental_system/features/auth/models/user_model.dart';

class MessageModel {
  MessageModel({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.isRead,
    this.bookingId,
    required this.createdAt,
  });

  final int id;
  final String sender;
  final String receiver;
  final String content;
  final bool isRead;
  final int? bookingId;
  final DateTime createdAt;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      sender: json['sender'] as String,
      receiver: json['receiver'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool,
      bookingId: json['booking_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'receiver': receiver,
      'content': content,
      'is_read': isRead,
      'booking_id': bookingId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ConversationModel {
  ConversationModel({
    required this.partner,
    required this.latestMessage,
  });

  final UserModel partner;
  final MessageModel latestMessage;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      partner: UserModel.fromJson(json['partner'] as Map<String, dynamic>),
      latestMessage: MessageModel.fromJson(json['latest_message'] as Map<String, dynamic>),
    );
  }
}
