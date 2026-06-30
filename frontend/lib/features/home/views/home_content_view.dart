import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/core/widgets/header_widget.dart';

class HomeContentView extends StatelessWidget {
  const HomeContentView({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(HomeController());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const HeaderWidget(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured Listings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'See All',
                  style: TextStyle(
                    color: Colors.blueAccent.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Obx(() {
            //   if (controller.isLoading.value) {
            //     return const Center(child: CircularProgressIndicator());
            //   }
            //   return ListView.builder(
            //     shrinkWrap: true,
            //     physics: const NeverScrollableScrollPhysics(),
            //     itemCount: controller.featuredProperties.length,
            //     itemBuilder: (context, index) {
            //       final property = controller.featuredProperties[index];
            //       return FeaturedPropertyCard(property: property);
            //     },
            //   );
            // }),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Rooms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'See All',
                  style: TextStyle(
                    color: Colors.blueAccent.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // SizedBox(
            //   height: 220,
            //   child: Obx(() {
            //     if (controller.isLoading.value) {
            //       return const Center(child: CircularProgressIndicator());
            //     }
            //     return ListView.builder(
            //       scrollDirection: Axis.horizontal,
            //       itemCount: controller.nearbyProperties.length,
            //       itemBuilder: (context, index) {
            //         final property = controller.nearbyProperties[index];
            //         return NearbyPropertyCard(property: property);
            //       },
            //     );
            //   }),
            // ),
            // const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
