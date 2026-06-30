import 'package:get/get.dart';
import 'package:room_rental_system/core/routes/app_routes.dart';

import 'package:room_rental_system/features/splash/views/splash_view.dart';
import 'package:room_rental_system/features/onboarding/views/onboarding_view.dart';
import 'package:room_rental_system/features/auth/views/register_view.dart';
import 'package:room_rental_system/features/auth/views/login_view.dart';
import 'package:room_rental_system/features/home/views/home_view.dart';
import 'package:room_rental_system/features/settings/views/settings_view.dart';
import 'package:room_rental_system/features/notifications/views/notifications_view.dart';
import 'package:room_rental_system/features/profile/views/profile_view.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => SplashView()),
    GetPage(name: AppRoutes.onboarding, page: () => OnboardingView()),
    GetPage(name: AppRoutes.register, page: () => RegisterView()),
    GetPage(name: AppRoutes.login, page: () => LoginView()),
    GetPage(name: AppRoutes.home, page: () => HomeView()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
    // GetPage(name: AppRoutes.notifications, page: () => const NotificationsView()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView(showAppBar: true)),
  ];
}
