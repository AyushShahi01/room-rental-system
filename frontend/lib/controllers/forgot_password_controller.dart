// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:room_rental_system/routes/app_routes.dart';
// import 'package:room_rental_system/services/auth_service.dart';

// class ForgotPasswordController extends GetxController {
//   final emailController = TextEditingController();
//   final otpController = TextEditingController();
//   final newPasswordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   Future<void> sendOtp(String email) async {
//     if (email.isEmpty) return;
//     try {
//       var response = await AuthService.forgotPassword(email);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Get.snackbar(
//           "Success",
//           "OTP sent to your email",
//           colorText: Colors.black,
//         );
//         Get.toNamed(AppRoutes.otpVerification);
//       } else {
//         Get.snackbar(
//           "Error",
//           "Failed to send OTP",
//           colorText: Colors.black,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         "Error",
//         "Something went wrong",
//         colorText: Colors.black,
//       );
//     }
//   }

//   Future<void> verifyOtp(String otp) async {
//     if (otp.length != 6) return;
//     try {
//       var response = await AuthService.verifyOtp(emailController.text, otp);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Get.snackbar(
//           "Success",
//           "OTP verified successfully",
//           colorText: Colors.black,
//         );
//         Get.toNamed(AppRoutes.resetPassword);
//       } else {
//         Get.snackbar(
//           "Error",
//           "Invalid OTP",
//           colorText: Colors.black,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         "Error",
//         "Something went wrong",
//         colorText: Colors.black,
//       );
//     }
//   }

//   Future<void> resetPassword() async {
//     if (newPasswordController.text != confirmPasswordController.text) {
//       Get.snackbar(
//         "Error",
//         "Passwords do not match",
//         colorText: Colors.black,
//       );
//       return;
//     }
//     try {
//       var response = await AuthService.resetPassword(
//         emailController.text,
//         newPasswordController.text,
//         confirmPasswordController.text,
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         Get.snackbar(
//           "Success",
//           "Password reset successfully",
//           colorText: Colors.black,
//         );
//         Get.offAllNamed(AppRoutes.login);
//       } else {
//         Get.snackbar(
//           "Error",
//           "Failed to reset password",
//           colorText: Colors.black,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         "Error",
//         "Something went wrong",
//         colorText: Colors.black,
//       );
//     }
//   }

//   @override
//   void onClose() {
//     emailController.dispose();
//     otpController.dispose();
//     newPasswordController.dispose();
//     confirmPasswordController.dispose();
//     super.onClose();
//   }
// }
