import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:room_rental_system/core/storage/token_storage.dart';
import 'package:room_rental_system/features/message/models/message_model.dart';
import 'package:room_rental_system/features/message/services/message_service.dart';

class MessageController extends GetxController {
  final _service = MessageService();

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;

  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxString activeRecipientId = ''.obs;

  StreamSubscription<MessageModel>? _wsSubscription;

  String? get currentUserId {
    final token = TokenStorage.getAccessToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final resp = utf8.decode(base64Url.decode(normalized));
        final data = jsonDecode(resp) as Map<String, dynamic>;
        return data['user_id']?.toString();
      }
    } catch (_) {}
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    connectToWebSocket();
  }

  @override
  void onClose() {
    _wsSubscription?.cancel();
    _service.disconnect();
    super.onClose();
  }

  Future<void> fetchConversations() async {
    try {
      isLoadingConversations.value = true;
      final list = await _service.getConversations();
      conversations.assignAll(list);
    } catch (e) {
      // Handle error silently or show a toast
    } finally {
      isLoadingConversations.value = false;
    }
  }

  Future<void> connectToWebSocket() async {
    final token = TokenStorage.getAccessToken();
    if (token == null) return;

    try {
      await _wsSubscription?.cancel();
      final stream = await _service.connectWebSocket(token);
      _wsSubscription = stream.listen(
        (message) {
          _handleIncomingMessage(message);
        },
        onError: (err) {
          Future.delayed(const Duration(seconds: 5), connectToWebSocket);
        },
        onDone: () {
          Future.delayed(const Duration(seconds: 5), connectToWebSocket);
        },
      );
    } catch (e) {
      Future.delayed(const Duration(seconds: 5), connectToWebSocket);
    }
  }

  void _handleIncomingMessage(MessageModel message) {
    final currentId = currentUserId;
    final partnerId = activeRecipientId.value;

    // Check if the message belongs to the current open chat detail screen
    final isFromActivePartner = (message.sender == partnerId && message.receiver == currentId) ||
                                 (message.sender == currentId && message.receiver == partnerId);

    if (isFromActivePartner) {
      // Insert in list if not already present
      if (!messages.any((m) => m.id == message.id)) {
        messages.add(message);
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }

      // If we are the receiver of this live message, mark it as read immediately
      if (message.receiver == currentId && !message.isRead) {
        _service.markReadViaWebSocket(message.id);
      }
    }

    // Refresh conversation list to show latest message preview
    fetchConversations();
  }

  Future<void> loadChatMessages(String recipientId) async {
    activeRecipientId.value = recipientId;
    messages.clear();

    try {
      isLoadingMessages.value = true;
      final list = await _service.getMessages(recipientId);
      messages.assignAll(list);
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Mark all unread messages from this sender as read
      final currentId = currentUserId;
      for (final msg in messages) {
        if (msg.receiver == currentId && !msg.isRead) {
          _service.markReadViaWebSocket(msg.id);
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      isLoadingMessages.value = false;
    }
  }

  void sendMessage(String content, {int? bookingId}) {
    final recipientId = activeRecipientId.value;
    if (content.trim().isEmpty || recipientId.isEmpty) return;

    _service.sendMessageViaWebSocket(recipientId, content.trim(), bookingId: bookingId);
  }
}
