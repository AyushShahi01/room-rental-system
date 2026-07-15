import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> pages = const [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Find Rooms Easily",
      "description": "Search rooms and flats from different locations.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Connect with Landlords",
      "description": "Directly contact landlords and property owners.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Start Your Journey",
      "description": "Find your perfect rental home quickly and easily.",
    },
  ];

  bool get isLastPage => currentPage.value == pages.length - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      goToLogin();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void goToLogin() {
    GetStorage().write('hasCompletedOnboarding', true);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
