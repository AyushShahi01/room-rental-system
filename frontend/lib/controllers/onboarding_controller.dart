import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/routes/app_routes.dart';
import '../models/onboarding_model.dart';

import '../services/onboarding_service.dart'; // We will create this

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  // Use Get.find to get the service if you inject it, or just use a new instance if it's a simple class.
  // For simplicity since it's an optional requirement, let's assume it's registered or we instantiate it here.
  final OnboardingService _onboardingService = Get.put(OnboardingService());

  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      title: "Find Your Perfect Room",
      description:
          "Discover thousands of rooms tailored to your preferences, budget, and location needs.",
      imagePath: "search",
    ),
    OnboardingModel(
      title: "Compare & Save Listings",
      description:
          "Compare prices, amenities, and locations to find the best deal that fits your budget.",
      imagePath: "compare",
    ),
    OnboardingModel(
      title: "Book Instantly, Move In Fast",
      description:
          "Secure your room with a tap, easily manage bookings, and start packing immediately.",
      imagePath: "flash",
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.animateToPage(
        currentPage.value + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void skip() {
    _finishOnboarding();
  }

  void _finishOnboarding() async {
    // Optionally save state
    await _onboardingService.markOnboardingCompleted();

    // Navigate to Login or Home based on requirements.
    // The user mentioned "Get Started navigates to Home/Login screen using GetX routing".
    // I will use Routes.LOGIN as standard after onboarding.
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
