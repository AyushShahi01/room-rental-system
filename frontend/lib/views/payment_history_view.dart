import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/payement_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/booking_controller.dart';
import '../models/auth_model/user_model.dart';
import 'payement_view.dart';
import 'message/chat_detail_view.dart';

class PaymentHistoryView extends StatefulWidget {
  const PaymentHistoryView({super.key});

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> with SingleTickerProviderStateMixin {
  final PaymentController _paymentController = Get.put(PaymentController());
  final BookingController _bookingController = Get.isRegistered<BookingController>()
      ? Get.find<BookingController>()
      : Get.put(BookingController());
  final AuthController _authController = Get.find<AuthController>();

  late TabController _tabController;
  bool _isLandlord = false;

  @override
  void initState() {
    super.initState();
    _isLandlord = _authController.currentUser.value?.role?.toLowerCase() == 'landlord';
    _tabController = TabController(length: _isLandlord ? 3 : 2, vsync: this);

    _refreshData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (_isLandlord) {
      await _paymentController.loadPaymentHistory();
      await _bookingController.loadIncomingBookings();
    } else {
      await _paymentController.loadMyPayments();
      await _bookingController.loadTenantBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Rent Payments', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _isLandlord ? Colors.indigo.shade700 : Colors.blueAccent.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: _isLandlord ? Colors.indigo.shade700 : Colors.blueAccent.shade700,
          tabs: [
            const Tab(text: 'Reminders & Status', icon: Icon(Icons.alarm)),
            if (_isLandlord) const Tab(text: 'Pending Approvals', icon: Icon(Icons.pending_actions)),
            Tab(text: _isLandlord ? 'Past Logs' : 'My Logs', icon: const Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersTab(colorScheme, theme),
          if (_isLandlord) _buildPendingApprovalsTab(colorScheme, theme),
          _buildLogsTab(colorScheme, theme),
        ],
      ),
    );
  }

  // ── REMINDERS TAB ──────────────────────────────────────────────────────────
  Widget _buildRemindersTab(ColorScheme colorScheme, ThemeData theme) {
    return Obx(() {
      final bool bookingsLoading = _bookingController.isLoading.value;
      final bool paymentsLoading = _paymentController.isLoading.value;

      if (bookingsLoading || paymentsLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_isLandlord) {
        // Landlord Tenant Reminders Panel
        final activeBookings = _bookingController.incomingBookings
            .where((b) => b.status?.toLowerCase() == 'approved')
            .toList();

        if (activeBookings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            title: 'No Active Tenants',
            subtitle: 'Reminders will show up when a booking is approved.',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeBookings.length,
            itemBuilder: (context, index) {
              final booking = activeBookings[index];
              
              // Calculate tenant payment status
              final tenantPayments = _paymentController.paymentHistory
                  .where((p) => p.booking?.id == booking.id && p.status?.toLowerCase() == 'verified')
                  .toList();
              
              tenantPayments.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

              DateTime nextDueDate = booking.createdAt ?? DateTime.now();
              if (tenantPayments.isNotEmpty && tenantPayments.first.createdAt != null) {
                nextDueDate = tenantPayments.first.createdAt!.add(const Duration(days: 30));
              } else {
                nextDueDate = nextDueDate.add(const Duration(days: 30));
              }

              final isOverdue = DateTime.now().isAfter(nextDueDate);
              final String statusText = isOverdue ? 'OVERDUE' : 'PAID';
              final Color statusColor = isOverdue ? Colors.red.shade700 : Colors.green.shade700;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              booking.tenantName ?? 'Tenant Name',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Room: ${booking.roomTitle ?? "Unknown Room"}', style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 4),
                      Text('Rent Amount: ₹${booking.roomPrice ?? "0"} / month', style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        'Next Rent Due: ${DateFormat('yMMMMd').format(nextDueDate)}',
                        style: TextStyle(color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600, fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _sendChatReminder(booking.tenantId, booking.tenantName, booking.roomTitle, booking.roomPrice),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Send Chat Reminder'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.indigo.shade700,
                              side: BorderSide(color: Colors.indigo.shade200),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      } else {
        // Tenant Rent Reminders Panel
        final activeBookings = _bookingController.tenantBookings
            .where((b) => b.status?.toLowerCase() == 'approved')
            .toList();

        if (activeBookings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No Rent Due',
            subtitle: 'Approved bookings will generate monthly reminders here.',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeBookings.length,
            itemBuilder: (context, index) {
              final booking = activeBookings[index];
              
              // Calculate payment status
              final myVerifiedPayments = _paymentController.myPayments
                  .where((p) => p.booking?.id == booking.id && p.status?.toLowerCase() == 'verified')
                  .toList();
              
              myVerifiedPayments.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

              DateTime nextDueDate = booking.createdAt ?? DateTime.now();
              if (myVerifiedPayments.isNotEmpty && myVerifiedPayments.first.createdAt != null) {
                nextDueDate = myVerifiedPayments.first.createdAt!.add(const Duration(days: 30));
              } else {
                nextDueDate = nextDueDate.add(const Duration(days: 30));
              }

              final isOverdue = DateTime.now().isAfter(nextDueDate);
              final String statusText = isOverdue ? 'RENT DUE' : 'RENT PAID';
              final Color statusColor = isOverdue ? Colors.orange.shade800 : Colors.green.shade700;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              booking.roomTitle ?? 'My Room',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoText('Landlord', booking.landlordName ?? 'Host'),
                      const SizedBox(height: 6),
                      _buildInfoText('Monthly Rent', '₹${booking.roomPrice ?? "0"}'),
                      const SizedBox(height: 6),
                      _buildInfoText(
                        'Rent Due Date', 
                        DateFormat('yMMMMd').format(nextDueDate),
                        valueColor: isOverdue ? Colors.red.shade700 : null,
                      ),
                      if (isOverdue) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: () {
                              Get.to(() => PaymentView(
                                    bookingId: booking.id!,
                                    roomName: booking.roomTitle ?? 'Room',
                                    amount: booking.roomPrice ?? '0',
                                    paymentStatus: 'pending',
                                  ));
                            },
                            icon: const Icon(Icons.payment_rounded),
                            label: const Text('Log Rent Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.blueAccent.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    });
  }

  // ── PENDING APPROVALS TAB (LANDLORD) ─────────────────────────────────────────
  Widget _buildPendingApprovalsTab(ColorScheme colorScheme, ThemeData theme) {
    return Obx(() {
      if (_paymentController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Filter all unverified pending payments
      final pendingLogs = _paymentController.paymentHistory
          .where((p) => p.status?.toLowerCase() == 'pending')
          .toList();

      if (pendingLogs.isEmpty) {
        return _buildEmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'All Logged Payments Verified',
          subtitle: 'No unverified rent logs found.',
        );
      }

      return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingLogs.length,
          itemBuilder: (context, index) {
            final payment = pendingLogs[index];
            final tenantName = payment.booking?.tenant?.username ?? 'Tenant';
            final roomName = payment.booking?.room?.title ?? 'Room';
            final refToken = payment.transactionToken ?? '';

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tenantName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Text(
                          '₹${payment.amount}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade700, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Logged Room: $roomName', style: TextStyle(color: Colors.grey.shade700)),
                    if (refToken.toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Reference: $refToken', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Logged At: ${payment.createdAt != null ? DateFormat('yMMMMd hh:mm a').format(payment.createdAt!.toLocal()) : "N/A"}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (payment.id != null) {
                              _paymentController.verifyTenantPayment(payment.id!);
                            }
                          },
                          icon: const Icon(Icons.verified_outlined, size: 18),
                          label: const Text('Verify & Confirm'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ── PAST LOGS TAB ───────────────────────────────────────────────────────────
  Widget _buildLogsTab(ColorScheme colorScheme, ThemeData theme) {
    return Obx(() {
      if (_paymentController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final list = _isLandlord ? _paymentController.paymentHistory : _paymentController.myPayments;
      
      // Filter only verified logs for landlord, but show all logs (including pending/failed) for tenants
      final logs = _isLandlord 
          ? list.where((p) => p.status?.toLowerCase() == 'verified').toList()
          : list;

      if (logs.isEmpty) {
        return _buildEmptyState(
          icon: Icons.history_toggle_off_rounded,
          title: 'No Payment Logs',
          subtitle: 'Completed manual payment logs will display here.',
        );
      }

      return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final payment = logs[index];
            final roomName = payment.booking?.room?.title ?? 'Room';
            final refToken = payment.transactionToken ?? '';
            final status = payment.status?.toLowerCase() ?? 'pending';

            final statusColor = status == 'verified' || status == 'paid' 
                ? Colors.green.shade700 
                : (status == 'pending' ? Colors.orange.shade800 : Colors.red.shade700);

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _isLandlord ? Colors.indigo.shade50 : Colors.blue.shade50,
                  foregroundColor: _isLandlord ? Colors.indigo.shade700 : Colors.blueAccent.shade700,
                  child: const Icon(Icons.check_circle_outline),
                ),
                title: Text(
                  '₹${payment.amount} — $roomName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLandlord)
                      Text('Tenant: ${payment.booking?.tenant?.username ?? "Unknown"}'),
                    if (refToken.toString().isNotEmpty)
                      Text('Ref: $refToken', style: const TextStyle(fontSize: 12)),
                    Text(
                      payment.createdAt != null 
                          ? DateFormat('yMMMMd hh:mm a').format(payment.createdAt!.toLocal()) 
                          : 'N/A',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _sendChatReminder(String? tenantId, String? tenantName, String? roomName, String? price) {
    if (tenantId == null) return;
    
    final tenantUser = UserModel(
      id: tenantId,
      username: tenantName,
      email: '',
      firstName: tenantName,
      lastName: '',
      role: 'tenant',
      tenantId: tenantId,
      landlordId: null,
      province: null,
      district: null,
      city: null,
      ward: null,
    );

    // Navigate to Chat screen and pre-send/prompt chat reminder text
    Get.to(() => ChatDetailView(partner: tenantUser));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Chat Reminder',
        'Use the chat history to send a quick reminder message to $tenantName.',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }
}
