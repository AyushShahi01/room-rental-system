import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification/notification_list_model.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';
import '../routes/app_routes.dart';
import 'auth_controller.dart';
import 'landlord_dashboard_controller.dart';

class NotificationController extends GetxController with WidgetsBindingObserver {
  final NotificationService _service = NotificationService();
  final AuthService _authService = AuthService();

  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var notifications = <Result>[].obs;
  // API notifications back the unread badge and notification actions.
  // For landlords, the page itself displays the dashboard's activity feed.
  var displayNotifications = <Result>[].obs;
  var filter = 'All'.obs;

  bool get currentUserIsLandlord {
    if (!Get.isRegistered<AuthController>()) return false;
    final auth = Get.find<AuthController>();
    return (auth.currentUser.value?.role ?? auth.selectedRole.value)
        .toLowerCase() == 'landlord';
  }

  int get unreadCount => notifications.where((element) => element.isRead == false).length;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchNotifications();
    initFCM();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // FCM shows notification payloads while the app is backgrounded/terminated.
    // Reconcile with the API when the user returns so the page and badge are current.
    if (state == AppLifecycleState.resumed && TokenStorage.hasTokens) {
      fetchNotifications();
    }
  }

  Future<void> initFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Initialize local notifications
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      // Request permission
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Request explicit notification permission for Android 13+
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap();
        },
      );

      // Create Android channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] Foreground message received: messageId=${message.messageId}');
        RemoteNotification? notification = message.notification;
        debugPrint('[FCM] Notification payload: title="${notification?.title}", body="${notification?.body}"');
        debugPrint('[FCM] Data payload: ${message.data}');

        // Refresh existing notifications list
        fetchNotifications();

        if (notification != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(),
            ),
          );
          debugPrint('[FCM] Local notification displayed via flutter_local_notifications');
        }
      });

      // Background clicked message listener (App opened from background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM] App opened from background notification: messageId=${message.messageId}');
        debugPrint('[FCM] Opened message data: ${message.data}');
        _handleNotificationTap();
      });

      // Terminated app clicked message listener (App opened from terminated)
      messaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('[FCM] App opened from terminated notification: messageId=${message.messageId}');
          debugPrint('[FCM] Terminated message data: ${message.data}');
          _handleNotificationTap();
        }
      });

      // Token refresh listener
      messaging.onTokenRefresh.listen((token) async {
        debugPrint('[FCM] Token refreshed: $token');
        if (TokenStorage.hasTokens) {
          try {
            await _authService.updateDeviceToken(fcmToken: token);
            debugPrint('[FCM] Refreshed FCM token uploaded to backend successfully');
          } catch (e) {
            debugPrint('[FCM] Failed to upload refreshed FCM token: $e');
          }
        } else {
          debugPrint('[FCM] User not logged in, skipping refreshed token upload');
        }
      });

      // If user is already logged in, upload the current token
      if (TokenStorage.hasTokens) {
        debugPrint('[FCM] User already has session on startup, uploading current FCM token...');
        await uploadFCMToken();
      } else {
        debugPrint('[FCM] No session tokens found on startup, skipping FCM token upload');
      }
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  Future<void> uploadFCMToken() async {
    debugPrint('[FCM] uploadFCMToken() initiated');
    if (!TokenStorage.hasTokens) {
      debugPrint('[FCM] uploadFCMToken aborted: no active user tokens in TokenStorage');
      return;
    }
    try {
      debugPrint('[FCM] Requesting current FCM token from Firebase...');
      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint('[FCM] Retrieved token from Firebase: $token');
      if (token != null) {
        debugPrint('[FCM] Sending token to backend /api/auth/device-token/ ...');
        await _authService.updateDeviceToken(fcmToken: token);
        debugPrint('[FCM] FCM token uploaded successfully: $token');
      } else {
        debugPrint('[FCM] Received null token from Firebase Messaging');
      }
    } catch (e, stack) {
      debugPrint('[FCM] Failed to retrieve or upload FCM token: $e\n$stack');
    }
  }

  void _handleNotificationTap() {
    if (TokenStorage.hasTokens) {
      Get.toNamed(AppRoutes.notifications);
    }
  }

  Future<void> fetchNotifications() async {
    debugPrint('[NotificationController] fetchNotifications() started');
    try {
      isLoading(true);
      hasError(false);

      debugPrint('[NotificationController] Calling getNotifications API...');
      final response = await _service.getNotifications();
      final apiNotifications = List<Result>.from(response.results);
      debugPrint('[NotificationController] getNotifications API returned ${apiNotifications.length} notifications');
      for (int i = 0; i < apiNotifications.length; i++) {
        debugPrint('[NotificationController] Notification [$i]: id=${apiNotifications[i].id}, content="${apiNotifications[i].content}", isRead=${apiNotifications[i].isRead}');
      }

      notifications.assignAll(apiNotifications);
      var pageItems = List<Result>.from(apiNotifications);

      // The landlord notification page also shows the exact activity feed used
      // by the dashboard. This calls the same dashboard loader/APIs, but never
      // feeds back into this controller, avoiding the previous refresh loop.
      if (currentUserIsLandlord &&
          Get.isRegistered<LandlordDashboardController>()) {
        final dashboard = Get.find<LandlordDashboardController>();
        await dashboard.loadDashboardData();
        pageItems = <Result>[];
        for (var i = 0; i < dashboard.recentActivities.length; i++) {
          final activity = dashboard.recentActivities[i];
          pageItems.add(Result(
            // Synthetic negative IDs cannot collide with notification API IDs.
            id: -(i + 1),
            content: '${activity.title}: ${activity.subtitle}',
            isRead: true,
            createdAt: activity.date,
            isDashboardActivity: true,
          ));
        }
      }

      pageItems.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      displayNotifications.assignAll(pageItems);
      debugPrint('[NotificationController] fetchNotifications() finished. Total page items: ${displayNotifications.length}, unreadCount: $unreadCount');
    } catch (e, stack) {
      debugPrint('[NotificationController] Error in fetchNotifications: $e\n$stack');
      hasError(true);
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshState() async {
    debugPrint('[NotificationController] refreshState() triggered');
    await fetchNotifications();
  }

  Future<void> markAsRead(int id) async {
    try {
      final index = notifications.indexWhere((element) => element.id == id);
      if (index != -1 &&
          !notifications[index].isDashboardActivity &&
          notifications[index].isRead == false) {
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
      if (notifications.any((item) =>
          item.id == id && item.isDashboardActivity)) {
        return;
      }
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
      return displayNotifications;
    }
    return displayNotifications.where((element) {
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
