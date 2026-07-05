import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payement_controller.dart';

class PaymentView extends StatefulWidget {
  final int recordId;
  final String roomName;
  final String amount;
  final String paymentStatus;

  const PaymentView({
    super.key,
    required this.recordId,
    required this.roomName,
    required this.amount,
    required this.paymentStatus,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final PaymentController controller = Get.put(PaymentController());
  String _selectedGateway = 'manual';
  final TextEditingController _refNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _refNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Log'),
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
                  Text('Payment Logged', 
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                  const SizedBox(height: 16),
                  Text('Your payment details have been logged. The landlord has been notified and will verify the payment.', 
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700)),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () {
                        controller.isSuccess.value = false;
                        Get.back();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Return to Ledger', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                _buildDetailRow('Invoice ID', widget.recordId.toString(), context),
                _buildDetailRow('Room Name', widget.roomName, context),
                _buildDetailRow('Amount', 'Rs. ${widget.amount}', context),
                _buildDetailRow('Status', widget.paymentStatus.toUpperCase(), context, 
                    color: _getStatusColor(widget.paymentStatus, colorScheme)),
                const SizedBox(height: 40),
                Text(
                  'Log Rent Payment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log manual payment (Cash, Bank transfer, or digital wallet transfer) so the landlord can verify it.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 16),
                _buildGatewayOption(
                  value: 'manual',
                  title: 'Manual Payment Log',
                  icon: Icons.monetization_on_outlined,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 20),
                Text(
                  'Transaction Reference / Notes',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _refNoteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter receipt #, transfer screenshot info, cash date, or wallet transaction details...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
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
                        controller.logRentPayment(
                          recordId: widget.recordId,
                          amount: widget.amount,
                          referenceNote: _refNoteController.text,
                        );
                      },
                      child: Text(
                        'Log Payment of Rs. ${widget.amount}',
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
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
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
      case 'verified':
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
