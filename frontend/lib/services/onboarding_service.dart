import 'package:get/get.dart';

class OnboardingService extends GetxService {
  // Use this service to manage persistent states such as shared preferences.
  // Example: SharedPreferences _prefs;

  Future<OnboardingService> init() async {
    // await SharedPreferences.getInstance();
    return this;
  }

  Future<void> markOnboardingCompleted() async {
    // Save state to shared preferences to skip onboarding next time
    // print("Onboarding marked as completed");
    // await _prefs.setBool('onboarding_completed', true);
  }

  bool isOnboardingCompleted() {
    // Return the value from shared preferences
    // return _prefs.getBool('onboarding_completed') ?? false;
    return false;
  }
}
