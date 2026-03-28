import 'package:flutter/material.dart';

// This file is currently obsolete since Booking Request is sent directly
// from RoomDetailScreen in the new flow.
class BookingRequestView extends StatelessWidget {
  const BookingRequestView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Request')),
      body: const Center(child: Text("This view is obsolete")),
    );
  }
}
