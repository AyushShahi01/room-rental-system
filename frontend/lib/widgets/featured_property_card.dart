import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/property_model.dart';
import '../models/room_model.dart';
import '../controllers/room_controller.dart';
import '../routes/app_routes.dart';

class FeaturedPropertyCard extends StatelessWidget {
  final PropertyModel property;

  const FeaturedPropertyCard({super.key, required this.property});

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
      margin: const EdgeInsets.only(bottom: 16),
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
          // Image and Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  property.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: property.status == 'AVAILABLE'
                        ? Colors.green.withValues(alpha: 0.9)
                        : Colors.orange.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    property.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'NPR ${property.price}/mo',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      property.location,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                // Room details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailIcon(
                      Icons.bed_outlined,
                      '${property.bedrooms} Bed',
                    ),
                    _buildDetailIcon(
                      Icons.bathtub_outlined,
                      '${property.bathrooms} Bath',
                    ),
                    _buildDetailIcon(
                      property.hasWifi ? Icons.wifi : Icons.wifi_off,
                      property.hasWifi ? 'WiFi' : 'No WiFi',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
   );
  }

  Widget _buildDetailIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
