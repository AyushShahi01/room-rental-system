
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:room_rental_system/controllers/forgot_password_controller.dart';

// class OtpVerificationView extends StatefulWidget {
//   const OtpVerificationView({super.key});

//   @override
//   State<OtpVerificationView> createState() => _OtpVerificationViewState();
// }

// class _OtpVerificationViewState extends State<OtpVerificationView> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final ForgotPasswordController controller =
//       Get.find<ForgotPasswordController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Verify OTP"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.black,
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 600),
//               child: Padding(
//                 padding: EdgeInsets.all(16.0.r),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     10.verticalSpace,
//                     Text(
//                       "Enter OTP",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 24.sp,
//                       ),
//                     ),
//                     8.verticalSpace,
//                     Text(
//                       "Enter the 6-digit OTP sent to your email",
//                       style: TextStyle(fontSize: 16.sp),
//                     ),
//                     32.verticalSpace,
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           TextFormField(
//                             controller: controller.otpController,
//                             keyboardType: TextInputType.number,
//                             maxLength: 6,
//                             decoration: const InputDecoration(
//                               prefixIcon: Icon(Icons.security),
//                               hintText: "Enter 6-digit OTP",
//                               labelText: "OTP",
//                               counterText: "",
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty)
//                                 return 'OTP required';
//                               if (value.length != 6) return 'Must be 6 digits';
//                               return null;
//                             },
//                           ),
//                           24.verticalSpace,
//                           SizedBox(
//                             width: double.infinity,
//                             height: 50,
//                             child: MaterialButton(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               color: Colors.blue,
//                               onPressed: () {
//                                 if (_formKey.currentState!.validate()) {
//                                   controller.verifyOtp(
//                                     controller.otpController.text,
//                                   );
//                                 }
//                               },
//                               child: const Text(
//                                 "Verify",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
