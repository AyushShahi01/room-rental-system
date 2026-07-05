import '../../utils/dio_connection.dart';

class MaintenanceModel {
    MaintenanceModel({
        required this.id,
        required this.tenantId,
        required this.tenantUsername,
        required this.room,
        required this.description,
        required this.status,
        required this.image,
        required this.createdAt,
    });

    final int? id;
    /// Raw tenant ID (UUID string or int)
    final String? tenantId;
    /// Display name parsed from nested tenant object, or null
    final String? tenantUsername;
    final int? room;
    final String? description;
    final String? status;
    final String? image;
    final DateTime? createdAt;

    /// Convenience: best display name for tenant
    String get tenantDisplay => tenantUsername ?? tenantId ?? 'Unknown';

    factory MaintenanceModel.fromJson(Map<String, dynamic> json){ 
        final tenantRaw = json["tenant"];
        String? tenantId;
        String? tenantUsername;
        if (tenantRaw is Map) {
            tenantId = tenantRaw["id"]?.toString();
            final String fName = tenantRaw["first_name"]?.toString() ?? '';
            final String lName = tenantRaw["last_name"]?.toString() ?? '';
            final String fullName = '$fName $lName'.trim();
            tenantUsername = fullName.isNotEmpty ? fullName : (tenantRaw["username"]?.toString());
        } else {
            tenantId = tenantRaw?.toString();
        }

        final roomRaw = json["room"];
        final int? room = roomRaw is Map
            ? (roomRaw["id"] as int?)
            : (roomRaw is int ? roomRaw : int.tryParse(roomRaw?.toString() ?? ''));

        String? image = json["image"]?.toString();
        if (image != null && image.isNotEmpty && !image.startsWith('http')) {
            final prefix = image.startsWith('/') ? '' : '/';
            image = '${DioConnection.baseDomain}$prefix$image';
        }

        return MaintenanceModel(
            id: json["id"],
            tenantId: tenantId,
            tenantUsername: tenantUsername,
            room: room,
            description: json["description"],
            status: json["status"],
            image: image,
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
        );
    }

}
