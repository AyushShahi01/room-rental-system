import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/controllers/property_controller.dart';
import 'package:room_rental_system/widgets/header_widget.dart';
import 'package:room_rental_system/widgets/search_bar_widget.dart';
import 'package:room_rental_system/widgets/featured_property_card.dart';

class HomeContentView extends StatelessWidget {
  const HomeContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final propertyCtrl = Get.find<PropertyController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const HeaderWidget(),
            const SizedBox(height: 24),
            const SearchBarWidget(),
            const SizedBox(height: 24),
            const Text(
              'Available Rooms',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (propertyCtrl.propertyList.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No properties available right now.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: propertyCtrl.propertyList.length,
                itemBuilder: (context, index) {
                  final property = propertyCtrl.propertyList[index];
                  return FeaturedPropertyCard(property: property);
                },
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
