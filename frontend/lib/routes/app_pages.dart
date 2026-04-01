import 'package:get/get.dart';
import 'package:room_rental_system/routes/app_routes.dart';

import '../views/splash_view.dart';
import '../views/onboarding_view.dart';
import '../views/register_view.dart';
import '../views/login_view.dart';
import '../views/dashboard_screen.dart';
import '../views/settings_view.dart';
import '../views/notifications_view.dart';
import '../views/profile_view.dart';
import '../views/forgot_password_view.dart';
import '../views/verify_otp_view.dart';
import '../views/reset_password_view.dart';
import '../views/edit_profile_view.dart';

// Tenant Flow Views
import '../views/room_detail_screen.dart';
import '../views/booking_request_view.dart';
import '../views/payment_view.dart';
import '../views/maintenance_request_view.dart';

// Landlord Flow Views
import '../views/landlord/landlord_dashboard_screen.dart';

// Tenant Flow Bindings
import '../bindings/room_binding.dart';
import '../bindings/booking_binding.dart';
import '../bindings/payment_binding.dart';
import '../bindings/maintenance_binding.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => SplashView()),
    GetPage(name: AppRoutes.onboarding, page: () => OnboardingView()),
    GetPage(name: AppRoutes.register, page: () => RegisterView()),
    GetPage(name: AppRoutes.login, page: () => LoginView()),
    GetPage(name: AppRoutes.home, page: () => const DashboardScreen()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsView()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileView(showAppBar: true)),
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordView()),
    GetPage(name: AppRoutes.verifyOtp, page: () => const VerifyOtpView()),
    GetPage(name: AppRoutes.resetPassword, page: () => const ResetPasswordView()),
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileView()),

    // Tenant Flow Pages
    GetPage(
      name: AppRoutes.roomDetail, 
      page: () => const RoomDetailScreen(),
      binding: RoomBinding(),
    ),
    GetPage(
      name: AppRoutes.booking, 
      page: () => const BookingRequestView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.payment, 
      page: () => const PaymentView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: AppRoutes.maintenance, 
      page: () => const MaintenanceRequestView(),
      binding: MaintenanceBinding(),
    ),

    // Landlord Flow Pages
    GetPage(
      name: AppRoutes.landlordDashboard, 
      page: () => const LandlordDashboardScreen(),
    ),
  ];
}
