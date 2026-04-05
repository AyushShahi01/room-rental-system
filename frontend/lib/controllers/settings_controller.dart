import 'package:get/get.dart';
import 'package:room_rental_system/routes/app_routes.dart';

class SettingsController extends GetxController {
  final RxBool pushNotifications = true.obs;
  final RxBool emailMarketing = false.obs;

  final RxString profileVisibility = 'Public'.obs;

  final RxString language = 'English'.obs;

  void togglePushNotifications() =>
      pushNotifications.value = !pushNotifications.value;

  void toggleEmailMarketing() => emailMarketing.value = !emailMarketing.value;

  void toggleProfileVisibility() {
    profileVisibility.value = profileVisibility.value == 'Public'
        ? 'Private'
        : 'Public';
  }

  void goToNotifications() => Get.offNamed(AppRoutes.notifications);

  void goToProfile() => Get.offNamed(AppRoutes.profile);

  void logout() => Get.offNamed(AppRoutes.login);
}
