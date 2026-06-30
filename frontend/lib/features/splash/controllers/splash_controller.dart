import 'package:get/get.dart';
import 'package:room_rental_system/core/routes/app_routes.dart';
import 'package:room_rental_system/core/storage/token_storage.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (TokenStorage.hasTokens) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
