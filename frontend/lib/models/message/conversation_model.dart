import '../auth_model/user_model.dart';
import 'message_chat_model.dart';

class ConversationModel {
  final UserModel partner;
  final MessageChatModel latestMessage;

  ConversationModel({
    required this.partner,
    required this.latestMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      partner: UserModel.fromJson(json['partner'] as Map<String, dynamic>),
      latestMessage: MessageChatModel.fromJson(
          json['latest_message'] as Map<String, dynamic>),
    );
  }
}
