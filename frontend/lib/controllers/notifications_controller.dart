import 'package:get/get.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final String category;
  final bool isToday;
  RxBool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.isToday,
    bool read = false,
  }) : isRead = read.obs;
}

class NotificationsController extends GetxController {
  final RxInt selectedTab = 0.obs;

  final RxList<NotificationItem> notifications = <NotificationItem>[
    NotificationItem(
      id: '1',
      title: 'Rent Due Reminder',
      description: 'Your rent payment of Rs. 8,500 is due in 2 days.',
      time: '2 mins ago',
      category: 'rent',
      isToday: true,
    ),
    NotificationItem(
      id: '2',
      title: 'Booking Confirmed',
      description: 'Your booking for Room #204 has been confirmed.',
      time: '1 hour ago',
      category: 'bookings',
      isToday: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Maintenance Scheduled',
      description: 'Water supply maintenance on 24 Mar, 10 AM – 2 PM.',
      time: '3 hours ago',
      category: 'maintenance',
      isToday: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Rent Payment Received',
      description: 'Your March rent payment has been received. Thank you!',
      time: '2 days ago',
      category: 'rent',
      isToday: false,
    ),
    NotificationItem(
      id: '5',
      title: 'Booking Request',
      description: 'A new booking request has been sent for Room #101.',
      time: '3 days ago',
      category: 'bookings',
      isToday: false,
    ),
    NotificationItem(
      id: '6',
      title: 'Maintenance Complete',
      description: 'Internet maintenance in block B has been completed.',
      time: '5 days ago',
      category: 'maintenance',
      isToday: false,
    ),
    NotificationItem(
      id: '7',
      title: 'Rent Invoice Generated',
      description: 'April rent invoice has been generated. View details.',
      time: '1 week ago',
      category: 'rent',
      isToday: false,
    ),
  ].obs;

  final List<String> tabs = ['All', 'Rent', 'Bookings', 'Maintenance'];

  List<NotificationItem> get filteredNotifications {
    if (selectedTab.value == 0) return notifications;
    final category = tabs[selectedTab.value].toLowerCase();
    return notifications.where((n) => n.category == category).toList();
  }

  List<NotificationItem> get todayNotifications =>
      filteredNotifications.where((n) => n.isToday).toList();

  List<NotificationItem> get earlierNotifications =>
      filteredNotifications.where((n) => !n.isToday).toList();

  void selectTab(int index) => selectedTab.value = index;

  void markAllRead() {
    for (final n in notifications) {
      n.isRead.value = true;
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead.value).length;
}
