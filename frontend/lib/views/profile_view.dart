import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/token_storage.dart';
import '../routes/app_routes.dart';
import '../widgets/settings_tile.dart';
import '../models/auth_model/user_model.dart';


class ProfileView extends StatelessWidget {
  /// Set to true when navigated as a standalone route (e.g. from Settings).
  /// Wraps content in a full Scaffold with an AppBar.
  final bool showAppBar;

  const ProfileView({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    // Refresh user profile details when displaying this tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (TokenStorage.hasTokens) {
        authController.fetchCurrentUser();
      }
    });

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
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 2),
                      ),
                      child: Obx(() {
                        final user = authController.currentUser.value;
                        final picUrl = user?.absoluteProfilePictureUrl;
                        if (picUrl != null && picUrl.isNotEmpty) {
                          return ClipOval(
                            child: Image.network(
                              picUrl,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _initialsWidget(user),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return _initialsWidget(user);
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final user = authController.currentUser.value;
                    final fullName =
                        (user?.firstName != null || user?.lastName != null)
                        ? '${user?.firstName ?? ''} ${user?.lastName ?? ''}'
                              .trim()
                        : '';
                    return Column(
                      children: [
                        Text(
                          fullName.isNotEmpty
                              ? fullName
                              : authController.userName.value,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (fullName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '@${authController.userName.value}',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      authController.userEmail.value,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
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
                            authController.selectedRole.value.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      child: Obx(() {
                        final user = authController.currentUser.value;
                        final firstName = user?.firstName ?? '';
                        final lastName = user?.lastName ?? '';
                        final fullName = '$firstName $lastName'.trim();
                        final ward = user?.ward;
                        final city = user?.city;
                        final district = user?.district;
                        final province = user?.province;

                        final hasLocation =
                            (city != null && city.isNotEmpty) ||
                            (district != null && district.isNotEmpty) ||
                            (province != null && province.isNotEmpty) ||
                            ward != null;

                        return Column(
                          children: [
                            if (fullName.isNotEmpty) ...[
                              _detailRow(
                                Icons.badge_outlined,
                                'Full Name',
                                fullName,
                              ),
                              const Divider(height: 24),
                            ],
                            _detailRow(
                              Icons.person_outline,
                              'Username',
                              authController.userName.value,
                            ),
                            const Divider(height: 24),
                            _detailRow(
                              Icons.email_outlined,
                              'Email',
                              authController.userEmail.value,
                            ),
                            const Divider(height: 24),
                            _detailRow(
                              Icons.badge_outlined,
                              'Role',
                              authController.selectedRole.value.toUpperCase(),
                            ),
                            if (hasLocation) ...[
                              const Divider(height: 24),
                              _detailRow(
                                Icons.map_outlined,
                                'Location',
                                [
                                  if (ward != null) 'Ward $ward',
                                  if (city != null && city.isNotEmpty) city,
                                  if (district != null && district.isNotEmpty)
                                    district,
                                  if (province != null && province.isNotEmpty)
                                    province,
                                ].join(', '),
                              ),
                            ],
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Settings Section ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Settings',
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
                    child: SettingsTile(
                      icon: Icons.lock_outline,
                      iconColor: Colors.blueAccent,
                      title: 'Change Password',
                      onTap: () => Get.toNamed(AppRoutes.changePassword),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Actions Section ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.editProfile),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // ElevatedButton.icon(
                  //   onPressed: () => Get.toNamed(AppRoutes.settings),
                  //   icon: const Icon(Icons.settings_outlined),
                  //   label: const Text('Settings'),
                  //   style: ElevatedButton.styleFrom(
                  //     minimumSize: const Size.fromHeight(52),
                  //     backgroundColor: Colors.white,
                  //     foregroundColor: Colors.black87,
                  //     elevation: 0,
                  //     side: const BorderSide(color: Colors.grey),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(14),
                  //     ),
                  //     textStyle: const TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  Obx(
                    () => ElevatedButton.icon(
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
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    final appBar = AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: showAppBar
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
              onPressed: () => Get.back(),
            )
          : null,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: appBar,
      body: content,
    );
  }

  String _initials(String? first, String? last, String? username) {
    if ((first ?? '').isNotEmpty && (last ?? '').isNotEmpty) {
      return '${first![0]}${last![0]}'.toUpperCase();
    }
    if ((first ?? '').isNotEmpty) return first![0].toUpperCase();
    if ((username ?? '').isNotEmpty) return username![0].toUpperCase();
    return '?';
  }

  Widget _initialsWidget(UserModel? user) {
    return Center(
      child: Text(
        _initials(
          user?.firstName,
          user?.lastName,
          user?.username,
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Text(
                value.isEmpty ? '—' : value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
