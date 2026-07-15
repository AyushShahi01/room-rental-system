import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/payement_controller.dart';
import '../../models/booking/bookinglist_model.dart' as booking_list;
import '../../models/payement/rent_record_model.dart';
import '../../models/maintenace/maintenace_list_model.dart' as maintenance_list;
import '../../models/auth_model/user_model.dart';
import '../../models/room/room_model.dart' as room_model;
import '../../services/maintenance_service.dart';
import '../message/chat_detail_view.dart';

class RoomManagementView extends StatefulWidget {
  const RoomManagementView({super.key, required this.room});
  final room_model.Result room;

  @override
  State<RoomManagementView> createState() => _RoomManagementViewState();
}

class _RoomManagementViewState extends State<RoomManagementView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingController _bookingController = Get.isRegistered<BookingController>()
      ? Get.find<BookingController>()
      : Get.put(BookingController());
  final PaymentController _paymentController = Get.isRegistered<PaymentController>()
      ? Get.find<PaymentController>()
      : Get.put(PaymentController());
  final MaintenanceService _maintenanceService = MaintenanceService();

  booking_list.Result? _activeBooking;
  List<maintenance_list.Result> _maintenanceRequests = [];
  bool _isLoadingTenant = true;
  bool _isLoadingMaintenance = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _fetchActiveTenant(),
      _fetchRentRecords(),
      _fetchMaintenanceRequests(),
    ]);
  }

  Future<void> _fetchActiveTenant() async {
    setState(() {
      _isLoadingTenant = true;
    });
    try {
      await _bookingController.loadIncomingBookings(showLoading: false);
      final list = _bookingController.incomingBookings;
      // Find approved booking for this room
      final match = list.firstWhereOrNull(
        (b) => b.roomId == widget.room.id && b.status?.toLowerCase() == 'approved',
      );
      setState(() {
        _activeBooking = match;
        _isLoadingTenant = false;
      });
    } catch (e) {
      debugPrint('Error fetching active tenant: $e');
      setState(() {
        _isLoadingTenant = false;
      });
    }
  }

  Future<void> _fetchRentRecords() async {
    await _paymentController.loadRentRecords(
      showLoading: false,
      params: {'room': widget.room.id},
    );
  }

  Future<void> _fetchMaintenanceRequests() async {
    setState(() {
      _isLoadingMaintenance = true;
    });
    try {
      if (widget.room.id != null) {
        final res = await _maintenanceService.getMaintenanceByRoom(widget.room.id!);
        setState(() {
          _maintenanceRequests = res.results;
          _isLoadingMaintenance = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching maintenance requests: $e');
      setState(() {
        _isLoadingMaintenance = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          widget.room.title ?? 'Manage Room',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blueAccent.shade700,
          tabs: const [
            Tab(text: 'Tenant Info', icon: Icon(Icons.person_outline_rounded)),
            Tab(text: 'Rent Ledger', icon: Icon(Icons.receipt_long_outlined)),
            Tab(text: 'Maintenance', icon: Icon(Icons.build_circle_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTenantTab(colorScheme),
          _buildRentTab(colorScheme),
          _buildMaintenanceTab(colorScheme),
        ],
      ),
    );
  }

  // ── TENANT TAB ─────────────────────────────────────────────────────────────
  Widget _buildTenantTab(ColorScheme colorScheme) {
    if (_isLoadingTenant) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeBooking == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No active tenant assigned',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                'Once a tenant\'s booking is approved, their details will be shown here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final tenantName = _activeBooking!.tenantName ?? 'Tenant';
    final rentStartDateStr = _activeBooking!.rentStartDate ?? 'Not specified';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tenant Info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade50,
                  child: Text(
                    tenantName.isNotEmpty ? tenantName[0].toUpperCase() : 'T',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Active Tenant',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat button
                IconButton.filledTonal(
                  onPressed: () {
                    final tenantUser = UserModel(
                      id: _activeBooking!.tenantId,
                      username: _activeBooking!.tenantName,
                      email: '',
                      firstName: _activeBooking!.tenantName,
                      lastName: '',
                      role: 'tenant',
                      tenantId: _activeBooking!.tenantId,
                      landlordId: null,
                      province: null,
                      district: null,
                      city: null,
                      ward: null,
                    );
                    Get.to(() => ChatDetailView(
                          partner: tenantUser,
                          bookingId: _activeBooking!.id,
                        ));
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.blueAccent.shade700,
                    backgroundColor: Colors.blue.shade50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Rent Contract & Configuration details
          const Text(
            'Billing Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildInfoRow('Monthly Rent', 'Rs. ${widget.room.price ?? '0'}'),
                const Divider(height: 20),
                _buildInfoRow('Rent Start Date', rentStartDateStr),
                const Divider(height: 20),
                _buildInfoRow('Billing Cycle', 'Monthly (Calendar Basis)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  // ── RENT LEDGER TAB ────────────────────────────────────────────────────────
  Widget _buildRentTab(ColorScheme colorScheme) {
    return Obx(() {
      if (_paymentController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final List<RentRecordModel> records = _paymentController.rentRecords;

      if (records.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'No rent ledger records found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Monthly invoices will automatically appear here once the billing cycle begins.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _fetchRentRecords,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final record = records[index];
            final statusStr = record.status.toLowerCase();
            
            Color statusColor;
            Color statusBgColor;
            if (statusStr == 'paid') {
              statusColor = const Color(0xFF2E7D32);
              statusBgColor = const Color(0xFFE8F5E9);
            } else if (statusStr == 'overdue') {
              statusColor = const Color(0xFFC62828);
              statusBgColor = const Color(0xFFFFEBEE);
            } else if (statusStr == 'pending') {
              statusColor = const Color(0xFF0277BD);
              statusBgColor = const Color(0xFFE1F5FE);
            } else {
              statusColor = const Color(0xFFB78103);
              statusBgColor = const Color(0xFFFFF8E1);
            }

            final billingPeriod = '${_getMonthName(record.billingMonth)} ${record.billingYear}';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  // Invoice icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt_outlined, color: Colors.blueAccent.shade700),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          billingPeriod,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Due Date: ${record.dueDate}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        if (record.remarks.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Remarks: ${record.remarks}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. ${double.parse(record.amount).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusStr.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (statusStr != 'paid') ...[
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () => _markRecordAsPaid(record.id),
                      icon: const Icon(Icons.check),
                      tooltip: 'Mark as Paid',
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        backgroundColor: Colors.green.shade50,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Future<void> _markRecordAsPaid(int recordId) async {
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
      await _fetchRentRecords();
    }
  }

  String _getMonthName(int monthNum) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (monthNum >= 1 && monthNum <= 12) {
      return months[monthNum - 1];
    }
    return 'Month';
  }

  // ── MAINTENANCE TAB ────────────────────────────────────────────────────────
  Widget _buildMaintenanceTab(ColorScheme colorScheme) {
    if (_isLoadingMaintenance) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_maintenanceRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.build_circle_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No maintenance requests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                'Any service requests posted by the tenant will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMaintenanceRequests,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _maintenanceRequests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = _maintenanceRequests[index];
          final statusStr = (request.status ?? 'pending').toLowerCase();
          
          Color statusColor;
          Color statusBgColor;
          if (statusStr == 'resolved') {
            statusColor = const Color(0xFF2E7D32);
            statusBgColor = const Color(0xFFE8F5E9);
          } else if (statusStr == 'in_progress') {
            statusColor = const Color(0xFF0277BD);
            statusBgColor = const Color(0xFFE1F5FE);
          } else {
            statusColor = const Color(0xFFB78103);
            statusBgColor = const Color(0xFFFFF8E1);
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Maintenance Request',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusStr.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  request.description ?? 'No description provided.',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Requested on: ${request.createdAt?.toLocal().toString().split(' ')[0] ?? ''}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    if (statusStr != 'resolved') ...[
                      PopupMenuButton<String>(
                        onSelected: (newStatus) => _updateRequestStatus(request.id ?? 0, newStatus),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'in_progress', child: Text('Mark In Progress')),
                          PopupMenuItem(value: 'resolved', child: Text('Mark Resolved')),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Update Status',
                                style: TextStyle(
                                  color: Colors.blueAccent.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: Colors.blueAccent.shade700, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateRequestStatus(int requestId, String status) async {
    try {
      await _maintenanceService.updateMaintenanceStatus(requestId, status);
      Get.snackbar(
        'Success',
        'Request status updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
      await _fetchMaintenanceRequests();
    } catch (e) {
      debugPrint('Error updating request status: $e');
      Get.snackbar(
        'Error',
        'Failed to update request status.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }
}
