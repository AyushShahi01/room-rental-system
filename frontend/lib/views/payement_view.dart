import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payement_controller.dart';

class PaymentView extends StatefulWidget {
  final int bookingId;
  final String roomName;
  final String amount;
  final String paymentStatus;

  const PaymentView({
    super.key,
    required this.bookingId,
    required this.roomName,
    required this.amount,
    required this.paymentStatus,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final PaymentController controller = Get.put(PaymentController());
  String _selectedGateway = 'khalti';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadMyPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Obx(() {
        if (controller.isSuccess.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle, color: Colors.green.shade700, size: 80),
                  ),
                  const SizedBox(height: 32),
                  Text('Payment Successful', 
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                  const SizedBox(height: 16),
                  Text('Your payment has been successfully processed and your booking is confirmed.', 
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700)),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Return to Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadMyPayments(showLoading: false);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Details',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Booking ID', widget.bookingId.toString(), context),
                _buildDetailRow('Room Name', widget.roomName, context),
                _buildDetailRow('Amount', '₹${widget.amount}', context),
                _buildDetailRow('Status', widget.paymentStatus.toUpperCase(), context, 
                    color: _getStatusColor(widget.paymentStatus, colorScheme)),
                const SizedBox(height: 40),
                Text(
                  'Select Payment Gateway',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildGatewayOption(
                  value: 'khalti',
                  title: 'Khalti',
                  icon: Icons.account_balance_wallet,
                  color: Colors.purple.shade700,
                ),
                const SizedBox(height: 12),
                _buildGatewayOption(
                  value: 'esewa',
                  title: 'eSewa',
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: Obx(() {
                    if (controller.isSubmitting.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return FilledButton(
                      onPressed: () {
                        controller.processPayment(
                          bookingId: widget.bookingId,
                          amount: widget.amount,
                          gateway: _selectedGateway,
                        );
                      },
                      child: Text(
                        'Pay ₹${widget.amount}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 32),
                Text(
                  'Previous Payment History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final history = controller.myPayments.where((p) => p.booking?.id == widget.bookingId).toList();
                  if (history.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No payment history for this booking.', style: TextStyle(color: Colors.grey.shade600)),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final payment = history[index];
                      final status = payment.status?.toLowerCase() ?? 'pending';
                      final gateway = payment.paymentGateway?.toUpperCase() ?? 'UNKNOWN';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            gateway == 'KHALTI' ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
                            color: gateway == 'KHALTI' ? Colors.purple.shade700 : Colors.green.shade700,
                          ),
                          title: Text('₹${payment.amount ?? '0'} via $gateway'),
                          subtitle: Text(payment.createdAt != null ? payment.createdAt!.toLocal().toString().split('.')[0] : 'N/A'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status, colorScheme).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(status, colorScheme),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayOption({
    required String value,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedGateway == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGateway = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: color)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'failed':
        return Colors.red.shade700;
      default:
        return colorScheme.primary;
    }
  }
}
