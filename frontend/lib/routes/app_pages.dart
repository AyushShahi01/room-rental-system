import 'package:get/get.dart';
import 'package:room_rental_system/routes/app_routes.dart';

import 'package:room_rental_system/views/splash_view.dart';
import 'package:room_rental_system/views/onboarding_view.dart';
import 'package:room_rental_system/views/register_view.dart';
import 'package:room_rental_system/views/login_view.dart';
import 'package:room_rental_system/views/settings_view.dart';
import 'package:room_rental_system/views/notifications_view.dart';
import 'package:room_rental_system/views/forgot_password_view.dart';
import 'package:room_rental_system/views/verify_otp_view.dart';
import 'package:room_rental_system/views/reset_password_view.dart';
import 'package:room_rental_system/views/edit_profile_view.dart';

import 'package:room_rental_system/views/tenant/tenant_dashboard.dart';
import 'package:room_rental_system/views/tenant/profile_view.dart';
import 'package:room_rental_system/views/tenant/maintenance_request_view.dart';

import 'package:room_rental_system/views/room_detail_screen.dart';
import 'package:room_rental_system/views/booking_request_view.dart';
import 'package:room_rental_system/views/payment_view.dart';

import 'package:room_rental_system/views/landlord/landlord_dashboard.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => SplashView()),
    GetPage(name: AppRoutes.onboarding, page: () => OnboardingView()),
    GetPage(name: AppRoutes.register, page: () => RegisterView()),
    GetPage(name: AppRoutes.login, page: () => LoginView()),
    GetPage(name: AppRoutes.home, page: () => const TenantDashboardScreen()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(showAppBar: true),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
    GetPage(name: AppRoutes.verifyOtp, page: () => const VerifyOtpView()),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
    ),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileView()),

    GetPage(name: AppRoutes.roomDetail, page: () => const RoomDetailScreen()),
    GetPage(name: AppRoutes.booking, page: () => const BookingRequestView()),
    GetPage(name: AppRoutes.payment, page: () => const PaymentView()),
    GetPage(
      name: AppRoutes.maintenance,
      page: () => const MaintenanceRequestView(hideAppBar: false),
    ),
    GetPage(
      name: AppRoutes.landlordDashboard,
      page: () => const LandlordDashboardScreen(),
    ),
  ];
}
