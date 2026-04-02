import 'package:get/get.dart';

class MaintenanceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String tenantName;
  final String roomTitle;
  final RxString status; // 'Pending' or 'Resolved'

  MaintenanceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.tenantName = "Unknown Tenant",
    this.roomTitle = "Unknown Room",
    String status = "Pending",
  }) : status = status.obs;
}
