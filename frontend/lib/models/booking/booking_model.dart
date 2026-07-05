import '../../utils/dio_connection.dart';
import '../auth_model/user_model.dart';

class BookingModel {
  BookingModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.roomId,
    required this.roomTitle,
    required this.roomPrice,
    required this.roomProvince,
    required this.roomState,
    required this.tenantId,
    required this.tenantName,
    required this.landlordId,
    required this.landlordName,
    required this.roomImages,
    this.landlord,
    this.bookedDate,
    this.rentStartDate,
  });

  final int? id;
  final String? status;
  final DateTime? createdAt;

  final int? roomId;
  final String? roomTitle;
  final String? roomPrice;
  final String? roomProvince;
  final String? roomState;
  final List<String> roomImages;

  final String? tenantId;
  final String? tenantName;
  final String? landlordId;
  final String? landlordName;
  final UserModel? landlord;
  final String? bookedDate;
  final String? rentStartDate;

  int? get room => roomId;
  String? get tenant => tenantId;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final roomRaw = json['room'];
    int? roomId;
    String? roomTitle = json['room_title'] as String?;
    String? roomPrice = json['room_price'] as String?;
    String? roomProvince = json['room_province'] as String?;
    String? roomState = json['room_state'] as String?;

    List<String> parsedImages = [];
    if (roomRaw is Map) {
      roomId = roomRaw['id'] as int?;
      roomTitle ??= roomRaw['title']?.toString();
      roomPrice ??= roomRaw['price']?.toString();
      roomProvince ??= roomRaw['province']?.toString();
      roomState ??= roomRaw['state']?.toString();
      
      if (roomRaw['images'] != null && roomRaw['images'] is List) {
        for (var img in roomRaw['images']) {
          if (img is Map && img['image'] != null) {
            String url = img['image'].toString();
            if (!url.startsWith('http')) {
              url = DioConnection.baseDomain + (url.startsWith('/') ? '' : '/') + url;
            }
            parsedImages.add(url);
          } else if (img is String) {
            String url = img;
            if (!url.startsWith('http')) {
              url = DioConnection.baseDomain + (url.startsWith('/') ? '' : '/') + url;
            }
            parsedImages.add(url);
          }
        }
      }
    } else if (roomRaw != null) {
      roomId = roomRaw is int ? roomRaw : int.tryParse(roomRaw.toString());
    } else {
      roomId = json['room_id'] as int?;
    }

    final tenantRaw = json['tenant'];
    String? tenantId;
    String? tenantName = json['tenant_name'] as String?;
    if (tenantRaw is Map) {
      tenantId = tenantRaw['id']?.toString();
      final String fName = tenantRaw['first_name']?.toString() ?? '';
      final String lName = tenantRaw['last_name']?.toString() ?? '';
      final String fullName = '$fName $lName'.trim();
      tenantName = fullName.isNotEmpty ? fullName : (tenantRaw['username']?.toString() ?? tenantName);
    } else {
      tenantId = tenantRaw?.toString();
    }

    var landlordRaw = json['landlord'];
    if (landlordRaw == null && roomRaw is Map) {
      landlordRaw = roomRaw['landlord'];
    }
    String? landlordId = json['landlord_id']?.toString();
    String? landlordName = json['landlord_name'] as String?;
    if (landlordRaw is Map) {
      landlordId ??= landlordRaw['id']?.toString();
      landlordName ??= landlordRaw['username']?.toString() ?? landlordRaw['first_name']?.toString();
    }

    final landlordUser = landlordRaw != null
        ? UserModel.fromJson(Map<String, dynamic>.from(landlordRaw as Map))
        : (landlordId != null
            ? UserModel(
                id: landlordId,
                username: landlordName ?? 'Landlord',
                email: '',
                firstName: landlordName ?? 'Landlord',
                lastName: '',
                role: 'landlord',
                tenantId: null,
                landlordId: landlordId,
                province: null,
                district: null,
                city: null,
                ward: null,
              )
            : null);

    return BookingModel(
      id: json['id'] as int?,
      status: json['status'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      roomId: roomId,
      roomTitle: roomTitle,
      roomPrice: roomPrice,
      roomProvince: roomProvince,
      roomState: roomState,
      tenantId: tenantId,
      tenantName: tenantName,
      landlordId: landlordId,
      landlordName: landlordName,
      roomImages: parsedImages,
      landlord: landlordUser,
      bookedDate: json['booked_date'] as String?,
      rentStartDate: json['rent_start_date'] as String?,
    );
  }
}
