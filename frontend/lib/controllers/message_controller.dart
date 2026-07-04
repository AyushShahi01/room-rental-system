import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/message/message_chat_model.dart';
import '../models/message/conversation_model.dart';
import '../services/message_service.dart';
import '../utils/dio_connection.dart';
import '../utils/token_storage.dart';

class MessageController extends GetxController {
  final MessageService _messageService = MessageService();

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<MessageChatModel> messages = <MessageChatModel>[].obs;

  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSending = false.obs;

  WebSocket? _webSocket;
  bool _isConnecting = false;
  String? _activePartnerId;
  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    // Listen to currentUser in AuthController to connect/disconnect WebSocket
    _authWorker = ever(Get.find<AuthController>().currentUser, (user) {
      if (user != null) {
        connectWebSocket();
      } else {
        disconnectWebSocket();
      }
    });
    // If user is already logged in on startup, connect
    if (Get.find<AuthController>().currentUser.value != null) {
      connectWebSocket();
    }
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    disconnectWebSocket();
    super.onClose();
  }

  void connectWebSocket() async {
    if (_webSocket != null || _isConnecting) return;
    
    final token = TokenStorage.getAccessToken();
    if (token == null) return;
    
    _isConnecting = true;
    
    try {
      String baseDomain = DioConnection.baseDomain;
      String wsUrl;
      if (baseDomain.startsWith('https://')) {
        final domain = baseDomain.replaceFirst('https://', 'wss://');
        wsUrl = '$domain/ws/chat/?token=$token';
      } else if (baseDomain.startsWith('http://')) {
        final domain = baseDomain.replaceFirst('http://', 'ws://');
        wsUrl = '$domain/ws/chat/?token=$token';
      } else {
        wsUrl = 'ws://$baseDomain/ws/chat/?token=$token';
      }

      debugPrint('Connecting to WebSocket: $wsUrl');
      _webSocket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 10));
      _isConnecting = false;
      debugPrint('WebSocket Connected successfully');

      _webSocket!.listen(
        (data) {
          _onMessageReceived(data);
        },
        onError: (err) {
          debugPrint('WebSocket Error: $err');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('WebSocket Connection closed by server');
          _handleDisconnect();
        },
      );
    } catch (e) {
      _isConnecting = false;
      debugPrint('Failed to connect to WebSocket: $e');
      // Reconnect after delay if user is still logged in
      if (Get.find<AuthController>().currentUser.value != null) {
        Future.delayed(const Duration(seconds: 5), () => connectWebSocket());
      }
    }
  }

  void _onMessageReceived(dynamic textData) {
    try {
      final Map<String, dynamic> data = json.decode(textData as String);
      final String type = data['type'] ?? '';
      if (type == 'chat_message') {
        final messageData = data['message'];
        if (messageData != null) {
          final receivedMsg = MessageChatModel.fromJson(messageData as Map<String, dynamic>);
          
          final partnerId = _activePartnerId;
          final currentUserId = Get.find<AuthController>().currentUser.value?.id?.toString();
          
          final senderId = receivedMsg.sender?.id?.toString();
          final receiverId = receivedMsg.receiver?.id?.toString();

          if (partnerId != null) {
            if ((senderId == partnerId && receiverId == currentUserId) || 
                (senderId == currentUserId && receiverId == partnerId)) {
              
              final alreadyExists = messages.any((m) => m.id == receivedMsg.id);
              if (!alreadyExists) {
                messages.add(receivedMsg);
                
                if (senderId == partnerId && receivedMsg.id != null) {
                  markMessageAsRead(receivedMsg.id!);
                }
              }
            }
          }
          fetchConversations();
        }
      }
    } catch (e) {
      debugPrint('Error parsing received WebSocket message: $e');
    }
  }

  void _handleDisconnect() {
    _webSocket = null;
    if (Get.find<AuthController>().currentUser.value != null) {
      Future.delayed(const Duration(seconds: 5), () => connectWebSocket());
    }
  }

  void disconnectWebSocket() {
    _webSocket?.close();
    _webSocket = null;
    _isConnecting = false;
  }

  Future<void> fetchConversations() async {
    try {
      isLoadingConversations.value = true;
      final list = await _messageService.getConversations();
      conversations.assignAll(list);
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<void> fetchMessages(String partnerId, {bool silent = false}) async {
    try {
      if (!silent) isLoadingMessages.value = true;
      final list = await _messageService.getMessages(partnerId);
      
      if (list.length != messages.length || 
          (list.isNotEmpty && messages.isNotEmpty && list.last.id != messages.last.id)) {
        messages.assignAll(list);
        
        for (var msg in list) {
          if (!msg.isRead && msg.sender?.id == partnerId && msg.id != null) {
            markMessageAsRead(msg.id!);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    } finally {
      if (!silent) isLoadingMessages.value = false;
    }
  }

  Future<void> sendChatMessage(
    String receiverId,
    String content, {
    int? bookingId,
  }) async {
    if (content.trim().isEmpty) return;

    if (_webSocket != null) {
      final payload = {
        'action': 'send_message',
        'receiver_id': receiverId,
        'content': content.trim(),
        if (bookingId != null) 'booking_id': bookingId,
      };
      try {
        _webSocket!.add(json.encode(payload));
        return; // WebSocket broadcast will trigger _onMessageReceived and add it to the list.
      } catch (e) {
        debugPrint('Failed to send via WebSocket, falling back to HTTP: $e');
      }
    }

    try {
      isSending.value = true;
      final sentMsg = await _messageService.sendMessage(
        receiverId,
        content.trim(),
        bookingId: bookingId,
      );
      if (!messages.any((m) => m.id == sentMsg.id)) {
        messages.add(sentMsg);
      }
      fetchConversations();
    } catch (e) {
      debugPrint('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> markMessageAsRead(int messageId) async {
    try {
      await _messageService.markAsRead(messageId);
    } catch (e) {
      debugPrint('Error marking message read: $e');
    }
  }

  void startChatSession(String partnerId) {
    _activePartnerId = partnerId;
    connectWebSocket();
    fetchMessages(partnerId, silent: true);
  }

  void stopChatSession() {
    _activePartnerId = null;
  }
}
