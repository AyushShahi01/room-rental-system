import 'package:get/get.dart';
import '../models/payment_model.dart';
import '../controllers/booking_controller.dart';

class PaymentController extends GetxController {
  var paymentHistory = <PaymentModel>[].obs;
  var selectedMethod = "eSewa".obs;

  final methods = ["eSewa", "Khalti", "Bank Transfer"];

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  void loadDummyData() {
    paymentHistory.value = [
      PaymentModel(
        id: "1",
        amount: 8000,
        date: "2023-10-01",
        method: "eSewa",
        status: "Paid",
      ),
      PaymentModel(
        id: "2",
        amount: 8000,
        date: "2023-09-01",
        method: "eSewa",
        status: "Paid",
      ),
      PaymentModel(
        id: "3",
        amount: 8000,
        date: "2023-08-01",
        method: "Khalti",
        status: "Paid",
      ),
    ];
  }

  void setMethod(String method) {
    selectedMethod.value = method;
  }

  void payNow() {
    Get.snackbar(
      "Processing",
      "Simulating ${selectedMethod.value} payment...",
      backgroundColor: Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onPrimary,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (Get.arguments != null) {
        final bookingId = Get.arguments as String;
        if (Get.isRegistered<BookingController>()) {
          Get.find<BookingController>().submitPayment(bookingId);
        }
      }
      Get.back();
      Get.snackbar(
        "Payment Successful",
        "Your payment has been processed.",
        backgroundColor: Get.theme.primaryColor,
      );
    });
  }
}
