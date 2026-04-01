import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;

  final onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Find Your Perfect Room",
      "desc": "Browse thousands of rooms and apartments near you.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Compare & Save Listings",
      "desc": "Read reviews, compare prices, and save your favorites.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Book Instantly, Move In Fast",
      "desc": "Secure your room with one tap. No paperwork hassles.",
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void goToNextOrLogin() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  void skip() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}