import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../utils/token_storage.dart';
import 'auth_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (TokenStorage.hasTokens) {
      final authController = Get.find<AuthController>();
      if (authController.currentUser.value == null) {
        await authController.fetchCurrentUser();
      }
      authController.navToHome();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
