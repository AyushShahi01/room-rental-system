import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/features/auth/controllers/auth_controller.dart';

class ProfileView extends StatelessWidget {
  /// Set to true when navigated as a standalone route (e.g. from Settings).
  /// Wraps content in a full Scaffold with an AppBar.
  final bool showAppBar;

  const ProfileView({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    // The core scrollable content (shared between both modes)
    final content = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [

            // ─── Header Banner ────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 56, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Text(
                        authController.userName.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        authController.userEmail.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      )),
                  const SizedBox(height: 12),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              authController.selectedRole.value == 'landlord'
                                  ? Icons.home_work
                                  : Icons.person_pin,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              authController.selectedRole.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Details Section ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Your Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Obx(() => Column(
                            children: [
                              _detailRow(
                                Icons.person,
                                'Username',
                                authController.userName.value,
                              ),
                              const Divider(height: 24),
                              _detailRow(
                                Icons.email,
                                'Email',
                                authController.userEmail.value,
                              ),
                              const Divider(height: 24),
                              _detailRow(
                                Icons.badge,
                                'Role',
                                authController.selectedRole.value,
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Logout ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() => ElevatedButton.icon(
                    onPressed: authController.isLoading.value
                        ? null
                        : authController.logout,
                    icon: authController.isLoading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    // Return a full Scaffold when navigated standalone (e.g. from Settings).
    if (showAppBar) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: content,
      );
    }

    return content;
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
