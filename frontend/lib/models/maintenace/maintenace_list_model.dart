import '../../utils/dio_connection.dart';

class MaintenanceListModel {
    MaintenanceListModel({
        required this.count,
        required this.next,
        required this.previous,
        required this.results,
    });

    final int? count;
    final String? next;
    final String? previous;
    final List<Result> results;

    factory MaintenanceListModel.fromJson(Map<String, dynamic> json){ 
        return MaintenanceListModel(
            count: json["count"],
            next: json["next"],
            previous: json["previous"],
            results: json["results"] == null ? [] : List<Result>.from(json["results"]!.map((x) => Result.fromJson(x))),
        );
    }

}

class Result {
    Result({
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

    factory Result.fromJson(Map<String, dynamic> json){ 
        final tenantRaw = json["tenant"];
        String? tenantId;
        String? tenantUsername;
        if (tenantRaw is Map<String, dynamic>) {
            tenantId = tenantRaw["id"]?.toString();
            tenantUsername = tenantRaw["username"]?.toString()
                ?? tenantRaw["first_name"]?.toString();
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

        return Result(
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
