import '../models/message/message_chat_model.dart';
import '../models/message/conversation_model.dart';
import '../utils/dio_connection.dart';

class MessageService {
  final _dio = DioConnection.dio;

  Future<List<ConversationModel>> getConversations() async {
    final response = await _dio.get('messages/conversations/');
    final data = response.data as Map<String, dynamic>;
    final list = data['results'] as List<dynamic>? ?? [];
    return list
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageChatModel>> getMessages(String partnerId) async {
    final response = await _dio.get(
      'messages/',
      queryParameters: {'recipient_id': partnerId},
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map<String, dynamic> && data['results'] != null) {
      list = data['results'] as List<dynamic>;
    } else if (data is List) {
      list = data;
    }
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
    final response = await _dio.post('messages/', data: payload);
    return MessageChatModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> markAsRead(int messageId) async {
    await _dio.patch('messages/$messageId/read/');
  }
}
