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
              url = 'https://room-rental-system-f5x8.onrender.com' + (url.startsWith('/') ? '' : '/') + url;
            }
            parsedImages.add(url);
          } else if (img is String) {
            String url = img;
            if (!url.startsWith('http')) {
              url = 'https://room-rental-system-f5x8.onrender.com' + (url.startsWith('/') ? '' : '/') + url;
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
      tenantName ??= tenantRaw['username']?.toString() ?? tenantRaw['first_name']?.toString();
    } else {
      tenantId = tenantRaw?.toString();
    }

    final landlordRaw = json['landlord'];
    String? landlordId = json['landlord_id']?.toString();
    String? landlordName = json['landlord_name'] as String?;
    if (landlordRaw is Map) {
      landlordId ??= landlordRaw['id']?.toString();
      landlordName ??= landlordRaw['username']?.toString() ?? landlordRaw['first_name']?.toString();
    }

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
    );
  }
}
