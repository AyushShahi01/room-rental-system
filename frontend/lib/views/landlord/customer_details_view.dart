import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerDetailsView extends StatelessWidget {
  const CustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              "Ram Bahadur",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Tenant Candidate",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5),
                ],
              ),
              child: const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.teal),
                    title: Text("Phone"),
                    subtitle: Text("+977 9800000000"),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.email, color: Colors.teal),
                    title: Text("Email"),
                    subtitle: Text("ram.b@example.com"),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.badge, color: Colors.teal),
                    title: Text("Verified Identity"),
                    subtitle: Text("Citizenship uploaded"),
                    trailing: Icon(Icons.check_circle, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        "Rejected",
                        "Booking request rejected",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Reject", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        "Approved",
                        "Booking request approved",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Approve",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
