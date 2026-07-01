import 'package:get/get.dart';
import 'package:room_rental_system/routes/app_routes.dart';

import '../views/splash_view.dart';
import '../views/onboarding_view.dart';
import '../views/register_view.dart';
import '../views/login_view.dart';
import '../views/tenant/tenant_main_view.dart';
import '../views/landlord/landlord_main_view.dart';
import '../views/settings_view.dart';
import '../views/notifications_view.dart';
import '../views/profile_view.dart';
import '../views/edit_profile_view.dart';
import '../views/change_password_view.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => SplashView()),
    GetPage(name: AppRoutes.onboarding, page: () => OnboardingView()),
    GetPage(name: AppRoutes.register, page: () => RegisterView()),
    GetPage(name: AppRoutes.login, page: () => LoginView()),
    GetPage(
      name: AppRoutes.tenantDashboard,
      page: () => const TenantMainView(),
    ),
    GetPage(
      name: AppRoutes.landlordDashboard,
      page: () => const LandlordMainView(),
    ),
    GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(showAppBar: true),
    ),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileView()),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
    ),
  ];
}
