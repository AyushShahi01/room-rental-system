import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:room_rental_system/core/routes/app_routes.dart';
import 'package:room_rental_system/features/message/controllers/message_controller.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageController messageController = Get.find<MessageController>();

    final mockRooms = [
      {
        'title': 'Premium Single Room with WiFi',
        'price': 'Rs. 8,000 / month',
        'location': 'Kathmandu, Ward 3',
        'landlordId': 'f86253f0-bc94-4ac6-b85f-fd5dba5eb0cd', // 'landlord' user
        'landlordName': 'landlord',
        'description': 'Fully furnished single room near main street. Includes high-speed internet and 24/7 water supply.',
      },
      {
        'title': 'Spacious Double Bed Room',
        'price': 'Rs. 12,000 / month',
        'location': 'Lalitpur, Ward 5',
        'landlordId': 'eb1edd98-0a2b-46be-a196-94781d8f9cdb', // 'suvu' user
        'landlordName': 'suvu',
        'description': 'Ideal for couples or students. Attached bathroom, private balcony, and peaceful environment.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockRooms.length,
        itemBuilder: (context, index) {
          final room = mockRooms[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    room['price']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['title']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(room['location']!, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        room['description']!,
                        style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.person, size: 14, color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Owner: ${room['landlordName']!}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.toNamed(
                                AppRoutes.chatDetail,
                                arguments: {
                                  'userId': room['landlordId'],
                                  'name': room['landlordName'],
                                  'role': 'landlord',
                                },
                              );
                              messageController.loadChatMessages(room['landlordId']!);
                            },
                            icon: const Icon(Icons.message_outlined, size: 16),
                            label: const Text('Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
