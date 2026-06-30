import 'package:flutter/material.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController pageController = PageController();

  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Find Rooms Easily",
      "description":
          "Search rooms and flats from different locations."
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Connect with Landlords",
      "description":
          "Directly contact landlords and property owners."
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Start Your Journey",
      "description":
          "Find your perfect rental home quickly and easily."
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isLastPage = currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to Login/Home
                },
                child: const Text("Skip"),
              ),
            ),

            /// PageView
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          pages[index]["image"]!,
                          height: 280,
                        ),

                        const SizedBox(height: 30),

                        Text(
                          pages[index]["title"]!,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          pages[index]["description"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// Indicators + Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: currentPage == index ? 25 : 8,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? Colors.blue
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (isLastPage) {
                        // Navigate to Login/Home
                      } else {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                    child: Text(
                      isLastPage ? "Get Started" : "Next",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}