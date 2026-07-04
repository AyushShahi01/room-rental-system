import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_controller.dart';
import '../message/chat_detail_view.dart';
import 'package:intl/intl.dart';

class LandlordMessagesView extends StatelessWidget {
  const LandlordMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();

    // Reload conversations on view render
    controller.fetchConversations();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Tenant Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Obx(() {
        if (controller.isLoadingConversations.value && controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.conversations.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchConversations,
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No tenant messages yet.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchConversations,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
            itemBuilder: (context, index) {
              final conversation = controller.conversations[index];
              final partnerName = '${conversation.partner.firstName ?? ""} ${conversation.partner.lastName ?? ""}'.trim();
              final displayName = partnerName.isNotEmpty ? partnerName : (conversation.partner.username ?? 'User');

              final latestMsg = conversation.latestMessage;
              final isPartnerSender = latestMsg.sender?.id == conversation.partner.id;
              final showUnreadBadge = isPartnerSender && !latestMsg.isRead;

              final String timeStr = latestMsg.createdAt != null
                  ? DateFormat('hh:mm a').format(latestMsg.createdAt!.toLocal())
                  : '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade50,
                  foregroundColor: Colors.indigo.shade700,
                  radius: 24,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontWeight: showUnreadBadge ? FontWeight.bold : FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: showUnreadBadge ? Colors.indigo.shade700 : Colors.grey.shade500,
                        fontWeight: showUnreadBadge ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          latestMsg.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: showUnreadBadge ? Colors.black87 : Colors.grey.shade600,
                            fontWeight: showUnreadBadge ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (showUnreadBadge)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
                onTap: () {
                  Get.to(() => ChatDetailView(partner: conversation.partner));
                },
              );
            },
          ),
        );
      }),
    );
  }
}
