import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/settings_tile.dart';

/// Settings page — accessible from the Profile tab's settings icon.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazily find/create controllers
    final SettingsController settingsCtrl = Get.find<SettingsController>();
    final AuthController authCtrl = Get.find<AuthController>();

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
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Notification icon in AppBar
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            tooltip: 'Notifications',
            onPressed: () => Get.offNamed(AppRoutes.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── User Profile Card ─────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 34, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  // Name & email
                  Expanded(
                    child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authCtrl.userName.value,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              authCtrl.userEmail.value.isEmpty
                                  ? 'No email set'
                                  : authCtrl.userEmail.value,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )),
                  ),
                  // Edit button
                  OutlinedButton(
                    onPressed: () => Get.offNamed(AppRoutes.profile),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── ACCOUNT & SECURITY ────────────────────────────────────────
            _SectionCard(
              title: 'ACCOUNT & SECURITY',
              children: [
                SettingsTile(
                  icon: Icons.lock_outline,
                  iconColor: Colors.indigo,
                  title: 'Change Password',
                  onTap: () {}, // Future implementation
                ),
                const _Divider(),
                SettingsTile(
                  icon: Icons.security_outlined,
                  iconColor: Colors.deepPurple,
                  title: 'Security',
                  subtitle: 'Two-factor authentication',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── PREFERENCES ──────────────────────────────────────────────
            Obx(() => _SectionCard(
                  title: 'PREFERENCES',
                  children: [
                    SettingsTile(
                      icon: Icons.notifications_active_outlined,
                      iconColor: Colors.blueAccent,
                      title: 'Push Notifications',
                      value: settingsCtrl.pushNotifications.value,
                      onToggle: (_) => settingsCtrl.togglePushNotifications(),
                    ),
                    const _Divider(),
                    SettingsTile(
                      icon: Icons.mark_email_unread_outlined,
                      iconColor: Colors.teal,
                      title: 'Email Marketing',
                      value: settingsCtrl.emailMarketing.value,
                      onToggle: (_) => settingsCtrl.toggleEmailMarketing(),
                    ),
                    const _Divider(),
                    SettingsTile(
                      icon: Icons.visibility_outlined,
                      iconColor: Colors.orange,
                      title: 'Profile Visibility',
                      trailingLabel: settingsCtrl.profileVisibility.value,
                      onTap: settingsCtrl.toggleProfileVisibility,
                    ),
                    const _Divider(),
                    SettingsTile(
                      icon: Icons.language_outlined,
                      iconColor: Colors.green,
                      title: 'Language',
                      trailingLabel: settingsCtrl.language.value,
                      onTap: () {},
                    ),
                  ],
                )),

            const SizedBox(height: 16),

            // ─── SUPPORT & LEGAL ───────────────────────────────────────────
            _SectionCard(
              title: 'SUPPORT & LEGAL',
              children: [
                SettingsTile(
                  icon: Icons.help_outline,
                  iconColor: Colors.blueGrey,
                  title: 'Help Center',
                  onTap: () {},
                ),
                const _Divider(),
                SettingsTile(
                  icon: Icons.headset_mic_outlined,
                  iconColor: Colors.cyan,
                  title: 'Contact Us',
                  onTap: () {},
                ),
                const _Divider(),
                SettingsTile(
                  icon: Icons.info_outline,
                  iconColor: Colors.amber,
                  title: 'About Smart Room',
                  subtitle: 'Version 1.0.0',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ─── Logout Button ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: settingsCtrl.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Private helper widgets ─────────────────────────────────────────────────

/// Section wrapper card with header label.
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

/// Thin divider between tiles inside a card.
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: Colors.grey.shade100,
    );
  }
}
