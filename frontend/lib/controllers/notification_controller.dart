import 'package:get/get.dart';
import '../models/notification/notification_list_model.dart';
import '../services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();

  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var notifications = <Result>[].obs;
  var filter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      hasError(false);
      final response = await _service.getNotifications();
      notifications.assignAll(response.results);
    } catch (e) {
      hasError(true);
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final index = notifications.indexWhere((element) => element.id == id);
      if (index != -1 && notifications[index].isRead == false) {
        await _service.markAsRead(id);
        await fetchNotifications();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark as read');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      await fetchNotifications();
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark all as read');
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _service.deleteNotification(id);
      await fetchNotifications();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete notification');
    }
  }

  void setFilter(String newFilter) {
    filter.value = newFilter;
  }

  List<Result> get filteredNotifications {
    if (filter.value == 'All') {
      return notifications;
    }
    return notifications.where((element) {
      final content = element.content?.toLowerCase() ?? '';
      
      final lowerFilter = filter.value.toLowerCase();
      if (lowerFilter == 'rent' && content.contains('rent')) return true;
      if (lowerFilter == 'bookings' && (content.contains('book') || content.contains('booking'))) return true;
      if (lowerFilter == 'maintenance' && content.contains('maintenance')) return true;
      
      return false;
    }).toList();
  }

  List<Result> get todayNotifications {
    final now = DateTime.now();
    return filteredNotifications.where((n) {
      if (n.createdAt == null) return false;
      return n.createdAt!.year == now.year &&
             n.createdAt!.month == now.month &&
             n.createdAt!.day == now.day;
    }).toList();
  }

  List<Result> get earlierNotifications {
    final now = DateTime.now();
    return filteredNotifications.where((n) {
      if (n.createdAt == null) return true;
      return !(n.createdAt!.year == now.year &&
               n.createdAt!.month == now.month &&
               n.createdAt!.day == now.day);
    }).toList();
  }
}
