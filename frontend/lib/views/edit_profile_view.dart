import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    // Pre-fill controllers immediately from cached user before the fetch returns
    final cached = authController.currentUser.value;
    if (cached != null) {
      authController.editFirstNameController.text = cached.firstName ?? '';
      authController.editLastNameController.text = cached.lastName ?? '';
      authController.editProvinceController.text = cached.province ?? '';
      authController.editDistrictController.text = cached.district ?? '';
      authController.editCityController.text = cached.city ?? '';
      authController.editWardController.text =
          cached.ward != null ? cached.ward.toString() : '';
    }

    // Then refresh from server in the background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.fetchCurrentUser();
    });

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
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final isLoading = authController.isLoading.value ||
            authController.isFetchingProfile.value;
        final user = authController.currentUser.value;

        return Stack(
          children: [
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Profile Avatar ────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _initials(user?.firstName, user?.lastName,
                              user?.username),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Read-Only Info ────────────────────────────────────────
                  _SectionHeader(title: 'ACCOUNT INFO (READ-ONLY)'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _readOnlyRow(
                          icon: Icons.person_outline,
                          label: 'Username',
                          value: user?.username ??
                              authController.userName.value,
                        ),
                        const Divider(height: 24),
                        _readOnlyRow(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: user?.email ??
                              authController.userEmail.value,
                        ),
                        const Divider(height: 24),
                        _readOnlyRow(
                          icon: Icons.badge_outlined,
                          label: 'Account Role',
                          value: (user?.role ??
                                  authController.selectedRole.value)
                              .toUpperCase(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Editable Fields ───────────────────────────────────────
                  _SectionHeader(title: 'PERSONAL DETAILS'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _customTextField(
                          controller:
                              authController.editFirstNameController,
                          labelText: 'First Name',
                          prefixIcon: Icons.badge,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _customTextField(
                          controller:
                              authController.editLastNameController,
                          labelText: 'Last Name',
                          prefixIcon: Icons.badge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _customTextField(
                    controller: authController.editProvinceController,
                    labelText: 'Province',
                    prefixIcon: Icons.map_outlined,
                  ),
                  const SizedBox(height: 16),

                  _customTextField(
                    controller: authController.editDistrictController,
                    labelText: 'District',
                    prefixIcon: Icons.explore_outlined,
                  ),
                  const SizedBox(height: 16),

                  _customTextField(
                    controller: authController.editCityController,
                    labelText: 'City',
                    prefixIcon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 16),

                  _customTextField(
                    controller: authController.editWardController,
                    labelText: 'Ward Number',
                    prefixIcon: Icons.numbers_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ─── Save Button ───────────────────────────────────────────
                  ElevatedButton(
                    onPressed:
                        isLoading ? null : authController.updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor:
                          Colors.blueAccent.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (isFetchingProfile(authController) && !authController.isLoading.value)
              Container(
                color: Colors.black.withValues(alpha: 0.08),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
              ),
          ],
        );
      }),
    );
  }

  bool isFetchingProfile(AuthController c) => c.isFetchingProfile.value;

  String _initials(String? first, String? last, String? username) {
    if ((first ?? '').isNotEmpty && (last ?? '').isNotEmpty) {
      return '${first![0]}${last![0]}'.toUpperCase();
    }
    if ((first ?? '').isNotEmpty) return first![0].toUpperCase();
    if ((username ?? '').isNotEmpty) return username![0].toUpperCase();
    return '?';
  }

  Widget _readOnlyRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 2),
            Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        // No hintText — field pre-filled with real user data
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF1565C0)),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
