import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ProfileView extends StatelessWidget {
  final bool showAppBar;

  const ProfileView({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    Widget body = SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 10),

                Obx(
                  () => Text(
                    auth.userName.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Obx(() => Text(auth.userEmail.value)),

                const SizedBox(height: 10),

                Obx(() => Chip(label: Text(auth.selectedRole.value))),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Obx(() {
            final role = auth.selectedRole.value;

            if (role == 'Admin') {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Admin Panel (connect backend later)',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Name'),
                    subtitle: Text(auth.userName.value),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(auth.userEmail.value),
                  ),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('Role'),
                    subtitle: Text(role),
                  ),
                  if (auth.userPhone.value.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Phone'),
                      subtitle: Text(auth.userPhone.value),
                    ),
                  if (auth.userAddress.value.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Address'),
                      subtitle: Text(auth.userAddress.value),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // 🔷 Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: auth.goToLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );

    // Optional AppBar
    return showAppBar
        ? Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: body,
          )
        : body;
  }
}
