import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';

class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the injected controller
    final BookingController ctrl = Get.find<BookingController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Booking Requests',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Approved"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FB),
        body: TabBarView(
          children: [
            _buildBookingList(ctrl, 'Pending'),
            _buildBookingList(ctrl, 'Approved'),
            _buildBookingList(ctrl, 'Rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BookingController ctrl, String statusFilter) {
    return Obx(() {
      final filteredBookings = ctrl.bookings
          .where((b) => b.status == statusFilter)
          .toList();

      if (filteredBookings.isEmpty) {
        return Center(
          child: Text(
            "No $statusFilter booking requests.",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          final room = booking.room;

          Color statusColor;
          if (booking.status == 'Approved')
            statusColor = Colors.green;
          else if (booking.status == 'Rejected')
            statusColor = Colors.red;
          else
            statusColor = Colors.orange;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  room?.imageUrl ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              title: Text(
                room?.title ?? 'Unknown Room',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Move-in: ${booking.moveInDate}'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      booking.status.value,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      );
    });
  }
}
