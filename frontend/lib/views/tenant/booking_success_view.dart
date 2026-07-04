import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tenant_dashboard_controller.dart';
import '../../models/booking/booking_model.dart';
import '../message/chat_detail_view.dart';

class BookingSuccessView extends StatelessWidget {
  const BookingSuccessView({super.key, required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.onSurface),
            onPressed: () {
              Get.until((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Beautiful success checkmark
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Booking Request Made!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              // Card with the required exact notification message
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'the booking request have been made please wait for the landloard to approve you can contact the landlord through our chat',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                      ),
                      if (booking.landlordName != null) ...[
                        const SizedBox(height: 16),
                        Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Landlord: ${booking.landlordName}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Primary button: Contact landlord
              if (booking.landlord != null) ...[
                FilledButton.icon(
                  onPressed: () {
                    Get.to(() => ChatDetailView(partner: booking.landlord!));
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Contact Landlord (Chat)'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Secondary button: View my bookings
              ElevatedButton.icon(
                onPressed: () {
                  if (Get.isRegistered<TenantDashboardController>()) {
                    Get.find<TenantDashboardController>().selectedIndex.value = 2; // Bookings tab
                  }
                  Get.until((route) => route.isFirst);
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Go to My Bookings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Back to home
              OutlinedButton(
                onPressed: () {
                  if (Get.isRegistered<TenantDashboardController>()) {
                    Get.find<TenantDashboardController>().selectedIndex.value = 0; // Home tab
                  }
                  Get.until((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
