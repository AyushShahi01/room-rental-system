import 'package:get/get.dart';
import 'package:room_rental_system/routes/app_routes.dart';

/// Controller for the Settings page.
/// Manages toggle states for notification/visibility preferences.
class SettingsController extends GetxController {
  // ─── ACCOUNT & SECURITY ──────────────────────────────────────────────────

  // ─── PREFERENCES ─────────────────────────────────────────────────────────
  final RxBool pushNotifications = true.obs;
  final RxBool emailMarketing = false.obs;

  /// Profile visibility: "Public" or "Private"
  final RxString profileVisibility = 'Public'.obs;

  /// Selected display language
  final RxString language = 'English'.obs;

  // ─── Helpers ─────────────────────────────────────────────────────────────

  void togglePushNotifications() =>
      pushNotifications.value = !pushNotifications.value;

  void toggleEmailMarketing() =>
      emailMarketing.value = !emailMarketing.value;

  void toggleProfileVisibility() {
    profileVisibility.value =
        profileVisibility.value == 'Public' ? 'Private' : 'Public';
  }

  /// Navigate to the Notifications page.
  void goToNotifications() => Get.toNamed(AppRoutes.notifications);

  /// Navigate to the Profile page (edit profile).
  void goToProfile() => Get.toNamed(AppRoutes.profile);

  /// Logout – delegate to AuthController via route.
  void logout() => Get.offAllNamed(AppRoutes.login);
}
