import 'package:flutter/material.dart';
import '../utils/app_color.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with scale and fade-in animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/splash_screen.png',
                  width: 120,
                  height: 120,
                ),
              ),

              const SizedBox(height: 30),

              // App Name & Tagline with fade-in animation
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: Column(
                  children: [
                    // RichText(
                    //   textAlign: TextAlign.center,
                    //   text: const TextSpan(
                    //     children: [
                    //       TextSpan(
                    //         text: "Room Rental ",
                    //         style: TextStyle(
                    //           fontSize: 34,
                    //           fontWeight: FontWeight.bold,
                    //           color: AppColor.primaryblue,
                    //           letterSpacing: 0.5,
                    //         ),
                    //       ),
                    //       TextSpan(
                    //         text: "System",
                    //         style: TextStyle(
                    //           fontSize: 34,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.blue,
                    //           letterSpacing: 0.5,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Room ",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0B3D91), // Dark Blue
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextSpan(
                            text: "Rental ",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF27A8F2), // Light Blue
                              letterSpacing: 0.5,
                            ),
                          ),
                          // TextSpan(
                          //   text: "System",
                          //   style: TextStyle(
                          //     fontSize: 34,
                          //     fontWeight: FontWeight.bold,
                          //     color: const Color(0xFF27A8F2), // Light Blue
                          //     letterSpacing: 0.5,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tagline
                    const Text(
                      "Find your perfect stay",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(137, 12, 0, 0),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
