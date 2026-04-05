import 'package:get/get.dart';

class MaintenanceModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String tenantName;
  final String propertyTitle;
  final RxString status;

  MaintenanceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.tenantName = "Unknown Tenant",
    this.propertyTitle = "Unknown Room",
    String status = "Pending",
  }) : status = status.obs;

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      tenantName: json['tenantName'] ?? 'Unknown Tenant',
      propertyTitle: json['propertyTitle'] ?? 'Unknown Room',
      status: json['status'] ?? 'Pending',
    );
  }
}
