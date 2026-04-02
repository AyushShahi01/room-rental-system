import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is globally injected, so Get.find() grabs the shared instance
    final BookingController ctrl = Get.find<BookingController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Booking Requests',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: Obx(() {
        if (ctrl.bookings.isEmpty) {
          return const Center(
            child: Text(
              "You have no booking requests.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: ctrl.bookings.length,
          itemBuilder: (context, index) {
            final booking = ctrl.bookings[index];
            final room = booking.room;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: Colors.black12,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (room?.imageUrl != null && room!.imageUrl.isNotEmpty) 
                              ? Image.network(
                                  room.imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _fallbackImage(),
                                )
                              : _fallbackImage(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room?.title ?? 'Unknown Room',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person_pin, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Landlord: ${room?.ownerName ?? 'Unknown'}",
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 16, color: Colors.blueAccent),
                            const SizedBox(width: 4),
                            Text("Move-in: ${booking.moveInDate}", style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        Obx(() {
                          Color statusColor;
                          if (booking.status.value == 'Approved') {
                            statusColor = Colors.green;
                          } else if (booking.status.value == 'Rejected') {
                            statusColor = Colors.red;
                          } else {
                            statusColor = Colors.orange;
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withOpacity(0.5)),
                            ),
                            child: Text(
                              booking.status.value,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.blue.shade50,
      child: const Icon(Icons.home, color: Colors.blueAccent, size: 30),
    );
  }
}
