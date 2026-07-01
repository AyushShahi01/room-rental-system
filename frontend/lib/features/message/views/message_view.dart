import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/core/routes/app_routes.dart';
import 'package:room_rental_system/features/message/controllers/message_controller.dart';
import 'package:room_rental_system/features/message/models/message_model.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final MessageController _controller = Get.find<MessageController>();
  final RxString _searchQuery = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // ─── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              onChanged: (val) => _searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2),
                ),
              ),
            ),
          ),

          // ─── Conversation list ───────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final query = _searchQuery.value.trim().toLowerCase();
              final filtered = _controller.conversations.where((conv) {
                final username = conv.partner.username?.toLowerCase() ?? '';
                final fullName = '${conv.partner.firstName ?? ''} ${conv.partner.lastName ?? ''}'.toLowerCase();
                return username.contains(query) || fullName.contains(query);
              }).toList();

              if (_controller.isLoadingConversations.value && filtered.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        query.isEmpty ? 'No messages yet' : 'No chats matching "$query"',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        query.isEmpty
                            ? 'Start a chat from exploring rooms!'
                            : 'Try searching a different name',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _controller.fetchConversations(),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final conversation = filtered[index];
                    final partner = conversation.partner;
                    final latest = conversation.latestMessage;
                    final myId = _controller.currentUserId;
                    final isSentByMe = latest.sender == myId;
                    final isUnread = !latest.isRead && !isSentByMe;

                    final timeStr = _formatTimestamp(latest.createdAt);

                    // Grab initials
                    final String initials = (partner.username ?? 'U').substring(0, 1).toUpperCase();

                    return InkWell(
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.chatDetail,
                          arguments: {
                            'userId': partner.id,
                            'name': partner.username ?? 'User',
                            'role': partner.role ?? 'tenant',
                          },
                        );
                        _controller.loadChatMessages(partner.id ?? '');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Beautiful avatar with gradient
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: partner.role == 'landlord'
                                      ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
                                      : [const Color(0xFF00796B), const Color(0xFF4DB6AC)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Content area
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        partner.username ?? 'User',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isUnread ? Colors.blueAccent : Colors.grey,
                                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isSentByMe ? 'You: ${latest.content}' : latest.content,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isUnread ? Colors.black87 : Colors.grey.shade600,
                                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (isUnread)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Colors.blueAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      final weekday = _getWeekdayName(dateTime.weekday);
      return weekday;
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _getWeekdayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
