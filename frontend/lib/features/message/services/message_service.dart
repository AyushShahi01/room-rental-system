import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:room_rental_system/core/network/dio_connection.dart';
import 'package:room_rental_system/features/message/models/message_model.dart';

class MessageService {
  final dio_pkg.Dio _dio = DioConnection.dio;
  WebSocket? _webSocket;

  String _getWebSocketUrl(String token) {
    final httpBaseUrl = _dio.options.baseUrl;
    String wsUrl;
    if (httpBaseUrl.startsWith('https://')) {
      wsUrl = httpBaseUrl.replaceFirst('https://', 'wss://');
    } else {
      wsUrl = httpBaseUrl.replaceFirst('http://', 'ws://');
    }
    
    wsUrl = wsUrl.replaceAll('/api/', '/ws/chat/');
    if (!wsUrl.endsWith('/')) {
      wsUrl = '$wsUrl/';
    }
    return '$wsUrl?token=$token';
  }

  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _dio.get('messages/conversations/');
      final data = response.data;
      final results = data['results'] as List<dynamic>;
      return results.map((item) => ConversationModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MessageModel>> getMessages(String recipientId) async {
    try {
      final response = await _dio.get('messages/', queryParameters: {'recipient_id': recipientId});
      final List<dynamic> results = response.data as List<dynamic>;
      return results.map((item) => MessageModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Stream<MessageModel>> connectWebSocket(String token) async {
    final wsUrl = _getWebSocketUrl(token);
    try {
      _webSocket = await WebSocket.connect(wsUrl);
      return _webSocket!.map((event) {
        final Map<String, dynamic> data = jsonDecode(event as String) as Map<String, dynamic>;
        if (data['type'] == 'chat_message') {
          return MessageModel.fromJson(data['message'] as Map<String, dynamic>);
        }
        throw Exception('Unknown message type: ${data['type']}');
      });
    } catch (e) {
      rethrow;
    }
  }

  void sendMessageViaWebSocket(String receiverId, String content, {int? bookingId}) {
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      final payload = {
        'action': 'send_message',
        'receiver_id': receiverId,
        'content': content,
        'booking_id': bookingId,
      };
      _webSocket!.add(jsonEncode(payload));
    }
  }

  void markReadViaWebSocket(int messageId) {
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      final payload = {
        'action': 'mark_read',
        'message_id': messageId,
      };
      _webSocket!.add(jsonEncode(payload));
    }
  }

  void disconnect() {
    _webSocket?.close();
    _webSocket = null;
  }
}
