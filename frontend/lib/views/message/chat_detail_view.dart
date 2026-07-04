import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/auth_model/user_model.dart';
import '../../models/message/message_chat_model.dart';
import 'package:intl/intl.dart';

class ChatDetailView extends StatefulWidget {
  const ChatDetailView({super.key, required this.partner, this.bookingId});

  final UserModel partner;
  final int? bookingId;

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final MessageController _messageController = Get.find<MessageController>();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messageController.fetchMessages(widget.partner.id ?? '');
    _messageController.startChatSession(widget.partner.id ?? '');
    
    // Scroll to bottom when list changes
    ever(_messageController.messages, (_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.stopChatSession();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.sendChatMessage(
      widget.partner.id ?? '',
      text,
      bookingId: widget.bookingId,
    );
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final partnerName = '${widget.partner.firstName ?? ""} ${widget.partner.lastName ?? ""}'.trim();
    final displayName = partnerName.isNotEmpty ? partnerName : (widget.partner.username ?? 'Chat Partner');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.primary,
              radius: 18,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.partner.role?.toUpperCase() ?? 'USER',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_messageController.isLoadingMessages.value && _messageController.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_messageController.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Say Hello! Start the conversation.',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messageController.messages.length,
                itemBuilder: (context, index) {
                  final message = _messageController.messages[index];
                  final isMe = message.sender?.id == _authController.currentUser.value?.id;
                  return _buildMessageBubble(message, isMe, theme);
                },
              );
            }),
          ),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageChatModel message, bool isMe, ThemeData theme) {
    final Alignment bubbleAlignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleBgColor = isMe ? theme.colorScheme.primary : Colors.white;
    final Color textColor = isMe ? Colors.white : Colors.black87;
    final BorderRadius borderRadius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    final String timeStr = message.createdAt != null
        ? DateFormat('hh:mm a').format(message.createdAt!.toLocal())
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: bubbleAlignment,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bubbleBgColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ),
          if (timeStr.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
              child: Text(
                timeStr,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, size: 18),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
