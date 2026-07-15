import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'bindings/controller_bindings.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'utils/app_color.dart';
import 'views/splash_view.dart';

@pragma('pragma:vm:entry-point')
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling background FCM message ID: ${message.messageId}");
  debugPrint("Background message notification title: ${message.notification?.title}");
  debugPrint("Background message notification body: ${message.notification?.body}");
  debugPrint("Background message data: ${message.data}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Firebase initialized");

  try {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    final settings = await FirebaseMessaging.instance.requestPermission();

    print("Permission Status: ${settings.authorizationStatus}");

    final token = await FirebaseMessaging.instance.getToken();

    print("FCM Token: $token");
  } catch (e) {
    print("FCM Exception: $e");
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Room Rental System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryblue),
      ),
      getPages: AppPages.pages,
      initialBinding: ControllerBindings(),
      home: SplashView(),
    );
  }
}
