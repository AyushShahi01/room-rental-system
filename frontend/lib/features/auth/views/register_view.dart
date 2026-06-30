import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/features/auth/controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              const Text(
                "Join Us Today!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Choose your role and create your account",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              const Text(
                "Select Role",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              /// ROLE CARDS
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.selectedRole.value = "tenant";
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color:
                                controller.selectedRole.value == "tenant"
                                    ? Colors.blue
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person,
                                size: 40,
                                color:
                                    controller.selectedRole.value == "tenant"
                                        ? Colors.white
                                        : Colors.blue,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Tenant",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      controller.selectedRole.value == "tenant"
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.selectedRole.value = "landlord";
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color:
                                controller.selectedRole.value == "landlord"
                                    ? Colors.blue
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.home_work,
                                size: 40,
                                color:
                                    controller.selectedRole.value == "landlord"
                                        ? Colors.white
                                        : Colors.blue,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Landlord",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      controller.selectedRole.value ==
                                              "landlord"
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// FULL NAME
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// EMAIL
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// PASSWORD
              Obx(
                () => TextField(
                  controller: controller.passwordController,
                  obscureText:
                      !controller.isRegisterPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isRegisterPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: controller
                          .toggleRegisterPasswordVisibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// PROVINCE
              TextField(
                controller: controller.provinceController,
                decoration: InputDecoration(
                  labelText: "Province",
                  prefixIcon: const Icon(Icons.map),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// DISTRICT
              TextField(
                controller: controller.districtController,
                decoration: InputDecoration(
                  labelText: "District",
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// CITY
              TextField(
                controller: controller.cityController,
                decoration: InputDecoration(
                  labelText: "City",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// WARD
              TextField(
                controller: controller.wardController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Ward",
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Register",
                            style: TextStyle(fontSize: 18),
                          ),
                  )),

              const SizedBox(height: 10),

              TextButton(
                onPressed: controller.goToLogin,
                child: const Text(
                  "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
