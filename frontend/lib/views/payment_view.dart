import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/controllers/payment_controller.dart';

class PaymentView extends StatelessWidget {
  const PaymentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PaymentController ctrl = Get.find<PaymentController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (ctrl.paymentHistory.isEmpty) {
                return const Text('No history found');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ctrl.paymentHistory.length,
                itemBuilder: (context, index) {
                  final pay = ctrl.paymentHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.payment, color: Colors.blue),
                    title: Text('Rs. ${pay.amount}'),
                    subtitle: Text('Date: ${pay.date} | Via: ${pay.method}'),
                    trailing: Text(
                      pay.status,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            }),
            const Divider(height: 32),

            const Text(
              'Make a Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Select Payment Method:'),
            const SizedBox(height: 8),
            Obx(
              () => Column(
                children: ctrl.methods.map((method) {
                  return RadioListTile<String>(
                    title: Text(method),
                    value: method,
                    groupValue: ctrl.selectedMethod.value,
                    onChanged: (val) {
                      if (val != null) ctrl.setMethod(val);
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: ctrl.payNow,
                child: const Text(
                  'Pay Now',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
