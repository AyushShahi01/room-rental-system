import 'package:get/get.dart';
import 'package:room_rental_system/routes/app_routes.dart';


class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));
    Get.offAllNamed(AppRoutes.onboarding);
  }
}
