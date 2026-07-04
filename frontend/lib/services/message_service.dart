import '../models/message/message_chat_model.dart';
import '../models/message/conversation_model.dart';
import '../utils/dio_connection.dart';

class MessageService {
  final _dio = DioConnection.dio;

  Future<List<ConversationModel>> getConversations() async {
    final response = await _dio.get('messaging/conversations/');
    final data = response.data as Map<String, dynamic>;
    final list = data['results'] as List<dynamic>? ?? [];
    return list
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageChatModel>> getMessages(String partnerId) async {
    final response = await _dio.get(
      'messaging/',
      queryParameters: {'recipient_id': partnerId},
    );
    final list = response.data as List<dynamic>? ?? [];
    return list
        .map((e) => MessageChatModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageChatModel> sendMessage(
    String receiverId,
    String content, {
    int? bookingId,
  }) async {
    final payload = {
      'receiver': receiverId,
      'content': content,
      if (bookingId != null) 'booking_id': bookingId,
    };
    final response = await _dio.post('messaging/', data: payload);
    return MessageChatModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> markAsRead(int messageId) async {
    await _dio.patch('messaging/$messageId/read/');
  }
}
