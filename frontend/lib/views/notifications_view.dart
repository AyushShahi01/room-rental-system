import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';
import '../models/notification/notification_list_model.dart';
import 'booking_view.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late final NotificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NotificationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all, color: Colors.blueAccent),
            onPressed: () => controller.markAllAsRead(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                );
              }
              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong.',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => controller.fetchNotifications(),
                        icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                        label: const Text('Retry', style: TextStyle(color: Colors.blueAccent)),
                      ),
                    ],
                  ),
                );
              }

              if (controller.filteredNotifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications here',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'re all caught up!',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchNotifications(),
                color: Colors.blueAccent,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  children: [
                    if (controller.todayNotifications.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, left: 4),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      ...controller.todayNotifications.map((n) => _buildNotificationCard(n, controller)).toList(),
                      const SizedBox(height: 16),
                    ],
                    if (controller.earlierNotifications.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, left: 4),
                        child: Text(
                          'Earlier',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      ...controller.earlierNotifications.map((n) => _buildNotificationCard(n, controller)).toList(),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(NotificationController controller) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          children: ['All', 'Rent', 'Bookings', 'Maintenance'].map((filter) {
            final isSelected = controller.filter.value == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 10, bottom: 10),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (_) => controller.setFilter(filter),
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.blueAccent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isSelected ? Colors.blueAccent : Colors.transparent,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Result notification, NotificationController controller) {
    final bool isRead = notification.isRead ?? true;
    final String content = notification.content ?? '';
    final DateTime? createdAt = notification.createdAt;
    
    String timeStr = '';
    if (createdAt != null) {
      timeStr = DateFormat('MMM d, h:mm a').format(createdAt.toLocal());
    }

    String title = 'Notification';
    IconData icon = Icons.notifications_active;
    Color iconColor = Colors.blueAccent;
    final contentLower = content.toLowerCase();
    
    if (contentLower.contains('rent') || contentLower.contains('payment') || contentLower.contains('paid')) {
      icon = Icons.payments_outlined;
      iconColor = Colors.green.shade600;
      title = 'Rent Update';
    } else if (contentLower.contains('book')) {
      icon = Icons.calendar_today_outlined;
      iconColor = Colors.orange.shade600;
      title = 'Booking Update';
    } else if (contentLower.contains('maintenance')) {
      icon = Icons.build_circle_outlined;
      iconColor = Colors.red.shade600;
      title = 'Maintenance Update';
    } else if (contentLower.contains('agreement') || contentLower.contains('contract') || contentLower.contains('lease')) {
      icon = Icons.description_outlined;
      iconColor = Colors.teal.shade600;
      title = 'Rental Agreement';
    } else if (contentLower.contains('message') || contentLower.contains('chat')) {
      icon = Icons.chat_outlined;
      iconColor = Colors.purple.shade600;
      title = 'New Message';
    } else if (contentLower.contains('room')) {
      icon = Icons.home_work_outlined;
      iconColor = Colors.blue.shade600;
      title = 'New Room Available';
    }

    final card = GestureDetector(
      onTap: () {
        if (!isRead && notification.id != null) {
          controller.markAsRead(notification.id!);
        }
        if (contentLower.contains('book')) {
          final match = RegExp(r'#?(\d+)').firstMatch(content);
          if (match != null && match.group(1) != null) {
            final bookingId = int.tryParse(match.group(1)!);
            if (bookingId != null) {
              Get.to(() => BookingDetailsView(bookingId: bookingId));
            }
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.blue.shade50.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isRead ? Colors.transparent : Colors.blue.withOpacity(0.15),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isRead ? Colors.grey.shade100 : iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(14),
              child: Icon(icon, color: isRead ? Colors.grey.shade500 : iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: isRead ? FontWeight.w600 : FontWeight.w700, color: isRead ? Colors.grey.shade800 : Colors.black87))),
                      if (!isRead) Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 4, left: 8), decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(content, style: TextStyle(fontSize: 14, color: isRead ? Colors.grey.shade600 : Colors.grey.shade800, fontWeight: isRead ? FontWeight.normal : FontWeight.w500, height: 1.4)),
                  const SizedBox(height: 10),
                  Row(children: [Icon(Icons.access_time, size: 14, color: Colors.grey.shade500), const SizedBox(width: 6), Text(timeStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (notification.isDashboardActivity) return card;

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => controller.deleteNotification(notification.id!),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: card,
    );
  }
}
