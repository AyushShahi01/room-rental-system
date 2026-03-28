import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/nav_controller.dart';

class RoomDetailView extends StatelessWidget {
  const RoomDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Get Controllers
    final RoomController roomCtrl = Get.find<RoomController>();
    final BookingController bookingCtrl = Get.find<BookingController>();
    final NavController navCtrl = Get.find<NavController>();

    return Scaffold(
      body: Obx(() {
        final room = roomCtrl.selectedRoom.value;
        if (room == null) return const Center(child: Text("No room selected"));

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Large top image with Back & Favorite buttons
              Stack(
                children: [
                  Image.network(
                    room.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white70,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white70,
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.red),
                        onPressed: () {
                          Get.snackbar("Favorite", "Added to favorites");
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3. Room title and price
                    Text(
                      room.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NPR ${room.price} / month',
                      style: const TextStyle(fontSize: 20, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    // 4. Location text
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          room.location,
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 5. Amenities row
                    const Text('Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: room.amenities.map((amenity) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_circle_outline, color: Colors.blue),
                            ),
                            const SizedBox(height: 4),
                            Text(amenity, style: const TextStyle(fontSize: 12)),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // 6. Description section
                    const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      room.description,
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 16),
                    
                    // 7. Map placeholder
                    const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Map View', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8. Owner info
                    const Text('Owner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(room.ownerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Verified Owner", style: TextStyle(color: Colors.green.shade600, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.phone, color: Colors.green),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      
      // Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final room = roomCtrl.selectedRoom.value;
              if (room != null) {
                // Generate booking and add to controller
                bookingCtrl.addBooking(room);
                Get.snackbar("Success", "Booking Request Sent");
                
                // Navigate back then switch tab
                Get.back(); // Pop Room Detail
                navCtrl.changeTab(2); // Switch Bottom Nav to Booking tab (index 2)
              }
            },
            child: const Text('Send Booking Request', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
