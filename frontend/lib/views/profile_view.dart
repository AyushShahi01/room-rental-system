import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class ProfileView extends StatelessWidget {
  final bool showAppBar;

  const ProfileView({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    String safe(String value) => value.isNotEmpty ? value : "N/A";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: showAppBar
          ? AppBar(
              title: const Text(
                'My Profile',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFFF8FAFC),
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
            )
          : null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 40,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white10,
                        ),
                      ),
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Color(0xFF38BDF8),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Obx(
                    () => Text(
                      safe(auth.userName.value),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Obx(
                    () => Text(
                      safe(auth.userEmail.value),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey.shade200,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        safe(auth.selectedRole.value).toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DETAILS CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Obx(() {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _row("Full Name", safe(auth.userName.value)),
                      _divider(),
                      _row("Email", safe(auth.userEmail.value)),
                      _divider(),
                      _row("Phone", safe(auth.userPhone.value)),
                      _divider(),
                      _row("Address", safe(auth.userAddress.value), true),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // ACTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _action(
                      "Edit",
                      Icons.edit,
                      () => Get.toNamed(AppRoutes.editProfile),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _action(
                      "Settings",
                      Icons.settings,
                      () => Get.toNamed(AppRoutes.settings),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // LOGOUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.login);
                },
                child: const Text("Logout"),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value, [bool last = false]) {
    return Padding(
      padding: EdgeInsets.all(16).copyWith(bottom: last ? 24 : 16),
      child: Row(
        children: [
          const Icon(Icons.info),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title),
                Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider();

  Widget _action(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon), const SizedBox(height: 8), Text(title)],
        ),
      ),
    );
  }
}
