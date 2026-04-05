import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/controllers/auth_controller.dart';
import 'package:room_rental_system/routes/app_routes.dart';

class ProfileView extends StatelessWidget {
  final bool showAppBar;

  const ProfileView({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    String safe(String value) => value.isNotEmpty ? value : "N/A";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar
          ? AppBar(
              title: const Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black87),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Text(
                        safe(auth.userName.value),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        safe(auth.userEmail.value),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blueGrey.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          auth.selectedRole.value.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Settings & Preferences",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.person_outline,
                      title: "Edit Profile",
                      onTap: () => Get.toNamed(AppRoutes.editProfile),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.settings_outlined,
                      title: "App Settings",
                      onTap: () => Get.toNamed(AppRoutes.settings),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.notifications_none,
                      title: "Notifications",
                      onTap: () => Get.toNamed(AppRoutes.notifications),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.logout,
                      title: "Logout",
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () => Get.offAllNamed(AppRoutes.login),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.blueGrey,
    Color textColor = const Color(0xFF1E293B),
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: 16,
          ),
        ),
        trailing: isLast
            ? null
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.15),
      indent: 70,
      endIndent: 20,
    );
  }
}
