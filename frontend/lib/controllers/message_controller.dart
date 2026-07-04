import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/message/message_chat_model.dart';
import '../models/message/conversation_model.dart';
import '../services/message_service.dart';

class MessageController extends GetxController {
  final MessageService _messageService = MessageService();

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<MessageChatModel> messages = <MessageChatModel>[].obs;

  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSending = false.obs;

  Timer? _messagePollTimer;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  @override
  void onClose() {
    stopMessagePolling();
    super.onClose();
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
      
      // Update list only if there's a difference in length or content to prevent unnecessary rebuilding
      if (list.length != messages.length || 
          (list.isNotEmpty && messages.isNotEmpty && list.last.id != messages.last.id)) {
        messages.assignAll(list);
        
        // Mark unread messages from partner as read
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
    try {
      isSending.value = true;
      final sentMsg = await _messageService.sendMessage(
        receiverId,
        content.trim(),
        bookingId: bookingId,
      );
      messages.add(sentMsg);
      // Refresh conversation list in background
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

  void startMessagePolling(String partnerId) {
    stopMessagePolling();
    _messagePollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      fetchMessages(partnerId, silent: true);
    });
  }

  void stopMessagePolling() {
    _messagePollTimer?.cancel();
    _messagePollTimer = null;
  }
}
