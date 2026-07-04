import 'rent_record_model.dart';

class RentDashboardModel {
  final double totalRentCollected;
  final double totalPendingRent;
  final int occupiedRoomsCount;
  final int vacantRoomsCount;
  final List<MonthlyRentCollection> monthlyRentCollection;
  final List<RoomWiseRentCollection> roomWiseRentCollection;
  final List<RentRecordModel> overdueTenants;

  RentDashboardModel({
    required this.totalRentCollected,
    required this.totalPendingRent,
    required this.occupiedRoomsCount,
    required this.vacantRoomsCount,
    required this.monthlyRentCollection,
    required this.roomWiseRentCollection,
    required this.overdueTenants,
  });

  factory RentDashboardModel.fromJson(Map<String, dynamic> json) {
    return RentDashboardModel(
      totalRentCollected: double.tryParse(json['total_rent_collected']?.toString() ?? '0.0') ?? 0.0,
      totalPendingRent: double.tryParse(json['total_pending_rent']?.toString() ?? '0.0') ?? 0.0,
      occupiedRoomsCount: json['occupied_rooms_count'] as int? ?? 0,
      vacantRoomsCount: json['vacant_rooms_count'] as int? ?? 0,
      monthlyRentCollection: (json['monthly_rent_collection'] as List<dynamic>? ?? [])
          .map((e) => MonthlyRentCollection.fromJson(e as Map<String, dynamic>))
          .toList(),
      roomWiseRentCollection: (json['room_wise_rent_collection'] as List<dynamic>? ?? [])
          .map((e) => RoomWiseRentCollection.fromJson(e as Map<String, dynamic>))
          .toList(),
      overdueTenants: (json['overdue_tenants'] as List<dynamic>? ?? [])
          .map((e) => RentRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonthlyRentCollection {
  final int billingYear;
  final int billingMonth;
  final double collected;
  final double pending;

  MonthlyRentCollection({
    required this.billingYear,
    required this.billingMonth,
    required this.collected,
    required this.pending,
  });

  factory MonthlyRentCollection.fromJson(Map<String, dynamic> json) {
    return MonthlyRentCollection(
      billingYear: json['billing_year'] as int? ?? 0,
      billingMonth: json['billing_month'] as int? ?? 0,
      collected: double.tryParse(json['collected']?.toString() ?? '0.0') ?? 0.0,
      pending: double.tryParse(json['pending']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class RoomWiseRentCollection {
  final int roomId;
  final String roomTitle;
  final double collected;
  final double pending;

  RoomWiseRentCollection({
    required this.roomId,
    required this.roomTitle,
    required this.collected,
    required this.pending,
  });

  factory RoomWiseRentCollection.fromJson(Map<String, dynamic> json) {
    return RoomWiseRentCollection(
      roomId: json['room_id'] as int? ?? 0,
      roomTitle: json['room_title']?.toString() ?? 'Unknown Room',
      collected: double.tryParse(json['collected']?.toString() ?? '0.0') ?? 0.0,
      pending: double.tryParse(json['pending']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}
