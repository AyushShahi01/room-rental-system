// import 'package:dio/dio.dart';
// import 'package:room_rental_system/controllers/storage_controller.dart';
// import 'package:room_rental_system/utils/dio_connection.dart';

// class AuthService {


//   static Future<Response> login(String email, String password) async {
//     return await DioConnection.dio.post(
//       "login",
//       queryParameters: {
//         "email": email,
//         "password": password,
//       },
//     );
//   }


//   static Future<Response> register(
//     String name,
//     String email,
//     String phone, // ✅ renamed
//     String password,
//     String countryCode,
//   ) async {
//     return await DioConnection.dio.post(
//       "register",
//       queryParameters: {
//         "name": name,
//         "email": email,
//         "phone": phone, // ✅ FIXED (was whatsapp)
//         "password": password,
//         "country_code": countryCode,
//       },
//     );
//   }


//   static Future<Response> fetchProfile() async {
//     var token = StorageController().getToken();

//     return await DioConnection.dio.get(
//       "profile",
//       options: Options(
//         headers: {
//           "Authorization": "Bearer $token",
//         },
//       ),
//     );
//   }


//   static Future<Response> forgotPassword(String email) async {
//     return await DioConnection.dio.post(
//       "forgot-password",
//       queryParameters: {
//         "email": email,
//       },
//     );
//   }


//   static Future<Response> verifyOtp(String email, String otp) async {
//     return await DioConnection.dio.post(
//       "verify-otp",
//       queryParameters: {
//         "email": email,
//         "otp": otp,
//       },
//     );
//   }

//   // ✅ RESET PASSWORD
//   static Future<Response> resetPassword(
//     String email,
//     String password,
//     String confirmPassword,
//   ) async {
//     return await DioConnection.dio.post(
//       "reset-password",
//       queryParameters: {
//         "email": email,
//         "password": password,
//         "password_confirmation": confirmPassword,
//       },
//     );
//   }
// }