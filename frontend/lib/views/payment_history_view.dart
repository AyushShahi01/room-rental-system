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
      await _paymentController.loadRentRecords();
      await _bookingController.loadIncomingBookings();
    } else {
      await _bookingController.loadTenantBookings();
      final tenantId = _authController.currentUser.value?.id;
      if (tenantId != null) {
        await _paymentController.loadRentRecords(
          showLoading: false,
          params: {'tenant': tenantId},
        );
      }
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
          labelColor: _isLandlord ? Colors.blueAccent.shade700 : Colors.blueAccent.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: _isLandlord ? Colors.blueAccent.shade700 : Colors.blueAccent.shade700,
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
        final unpaidRecords = _paymentController.rentRecords
            .where((r) => r.status == 'unpaid' || r.status == 'overdue' || r.status == 'partially_paid')
            .toList();

        if (unpaidRecords.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            title: 'No Pending Payments',
            subtitle: 'All tenants have cleared their rent. Excellent!',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: unpaidRecords.length,
            itemBuilder: (context, index) {
              final record = unpaidRecords[index];
              final isOverdue = record.status == 'overdue';
              final String statusText = record.status.replaceAll('_', ' ').toUpperCase();
              final Color statusColor = isOverdue ? Colors.red.shade700 : Colors.orange.shade800;

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
                              record.tenant.username ?? 'Tenant',
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
                      Text('Room: ${record.room.title}', style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 4),
                      Text('Rent Amount: Rs. ${record.amount}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        'Billing Month: ${_getMonthName(record.billingMonth)} ${record.billingYear}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rent Due Date: ${record.dueDate}',
                        style: TextStyle(color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600, fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _sendChatReminder(
                                record.tenant.id,
                                record.tenant.username,
                                record.room.title,
                                record.amount,
                              ),
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Send Chat Reminder'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blueAccent.shade700,
                                side: BorderSide(color: Colors.blue.shade200),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _markRecordAsPaidInHistory(record.id),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Mark Paid'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                              ),
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
      } else {
        // Tenant Rent Reminders Panel
        final unpaidRecords = _paymentController.rentRecords
            .where((r) => r.status != 'paid')
            .toList();

        if (unpaidRecords.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle_outline,
            title: 'All Rent Paid',
            subtitle: 'You have no pending or overdue rent records. Great job!',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: unpaidRecords.length,
            itemBuilder: (context, index) {
              final record = unpaidRecords[index];
              final isOverdue = record.status == 'overdue';
              final statusColor = isOverdue ? Colors.red.shade700 : Colors.orange.shade800;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 12),
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
                              record.room.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              record.status.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoText('Billing Month', '${_getMonthName(record.billingMonth)} ${record.billingYear}'),
                      const SizedBox(height: 6),
                      _buildInfoText('Monthly Rent', 'Rs. ${record.amount}'),
                      const SizedBox(height: 6),
                      _buildInfoText(
                        'Rent Due Date', 
                        record.dueDate,
                        valueColor: isOverdue ? Colors.red.shade700 : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () {
                            Get.to(() => PaymentView(
                                  recordId: record.id,
                                  roomName: record.room.title,
                                  amount: record.amount,
                                  paymentStatus: 'pending',
                                ));
                          },
                          icon: const Icon(Icons.payment_rounded),
                          label: const Text('Pay Rent Now', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                          ),
                        ),
                      ),
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

  String _getMonthName(int monthNum) {
    try {
      final date = DateTime(2026, monthNum, 1);
      return DateFormat('MMMM').format(date);
    } catch (_) {
      return 'Month $monthNum';
    }
  }

  // ── PENDING APPROVALS TAB (LANDLORD) ─────────────────────────────────────────
  Widget _buildPendingApprovalsTab(ColorScheme colorScheme, ThemeData theme) {
    return Obx(() {
      if (_paymentController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Filter all unverified pending payments from RentRecords
      final pendingRecords = _paymentController.rentRecords
          .where((r) => r.status.toLowerCase() == 'pending')
          .toList();

      if (pendingRecords.isEmpty) {
        return _buildEmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'All Logged Payments Verified',
          subtitle: 'No unverified rent statements found.',
        );
      }

      return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingRecords.length,
          itemBuilder: (context, index) {
            final record = pendingRecords[index];
            final tenantName = record.tenant.username ?? 'Tenant';
            final roomName = record.room.title;
            final refToken = record.remarks;
            final amountPaid = record.amountPaid;

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
                          'Rs. $amountPaid',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent.shade700, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Room: $roomName', style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 4),
                    Text(
                      'Statement: ${_getMonthName(record.billingMonth)} ${record.billingYear} (Total Due: Rs. ${record.amount})',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    if (refToken.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Reference/Notes:\n$refToken',
                          style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Logged At: ${DateFormat('yMMMMd hh:mm a').format(record.updatedAt.toLocal())}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _paymentController.updateRentRecordStatus(record.id, 'paid');
                            await _refreshData();
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

      // Filter paid rent statements
      final logs = _paymentController.rentRecords
          .where((r) => r.status.toLowerCase() == 'paid')
          .toList();

      if (logs.isEmpty) {
        return _buildEmptyState(
          icon: Icons.history_toggle_off_rounded,
          title: 'No Payment Logs',
          subtitle: 'Completed rent payments will display here.',
        );
      }

      return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final record = logs[index];
            final roomName = record.room.title;
            final refToken = record.remarks;
            final status = record.status;

            final statusColor = Colors.green.shade700;

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _isLandlord ? Colors.blue.shade50 : Colors.blue.shade50,
                  foregroundColor: _isLandlord ? Colors.blueAccent.shade700 : Colors.blueAccent.shade700,
                  child: const Icon(Icons.check_circle_outline),
                ),
                title: Text(
                  'Rs. ${record.amountPaid} — $roomName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLandlord)
                      Text('Tenant: ${record.tenant.username ?? "Unknown"}'),
                    Text('Billing Month: ${_getMonthName(record.billingMonth)} ${record.billingYear}'),
                    if (refToken.isNotEmpty)
                      Text('Ref: $refToken', style: const TextStyle(fontSize: 12)),
                    Text(
                      'Paid On: ${record.paymentDate ?? DateFormat('yMMMMd').format(record.updatedAt.toLocal())}',
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

  Future<void> _markRecordAsPaidInHistory(int recordId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Invoice as Paid'),
        content: const Text('Are you sure you want to mark this rent invoice as paid? (e.g. received via Cash/Direct Deposit)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _paymentController.updateRentRecordStatus(recordId, 'paid');
      await _refreshData();
    }
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
