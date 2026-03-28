import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';
import '../controllers/room_controller.dart';
import '../routes/app_routes.dart';

class NearbyPropertyCard extends StatelessWidget {
  final PropertyModel property;

  const NearbyPropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final RoomController roomCtrl = Get.find<RoomController>();
        roomCtrl.selectRoom(RoomModel(
          id: property.id,
          title: property.title,
          price: property.price.toDouble(),
          location: property.location,
          imageUrl: property.imageUrl,
          isAvailable: property.status == 'AVAILABLE',
          description: "Stunning property located perfectly in ${property.location}. It comes with ${property.bedrooms} bedrooms and ${property.bathrooms} bathrooms. Perfect for people looking for an affordable, cozy place.",
          ownerName: "Verified Owner",
          ownerPhone: "9800000000",
          amenities: [
            if (property.hasWifi) 'WiFi',
            '${property.bedrooms} Bed',
            '${property.bathrooms} Bath',
          ]
        ));
        Get.toNamed(AppRoutes.roomDetail);
      },
      child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              property.imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  property.location,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'NPR ${property.price}/mo',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
   );
  }
}
