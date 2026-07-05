import '../../utils/dio_connection.dart';
import '../auth_model/user_model.dart';

class BookingListModel {
    BookingListModel({
        required this.count,
        required this.next,
        required this.previous,
        required this.results,
    });

    final int? count;
    final String? next;
    final String? previous;
    final List<Result> results;

    factory BookingListModel.fromJson(Map<String, dynamic> json){ 
        return BookingListModel(
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
        this.tenantUser,
        this.rentStartDate,
        this.bookedDate,
    });

    final int? id;
    final String? status;
    final DateTime? createdAt;
    final int? roomId;
    final String? roomTitle;
    final String? roomPrice;
    final String? roomProvince;
    final String? roomState;
    final String? tenantId;
    final String? tenantName;
    final String? landlordId;
    final String? landlordName;
    final List<String> roomImages;
    final UserModel? tenantUser;
    final String? rentStartDate;
    final String? bookedDate;

    int? get room => roomId;
    String? get tenant => tenantId;

    factory Result.fromJson(Map<String, dynamic> json){ 
        final roomRaw = json["room"];
        int? roomId;
        String? roomTitle = json["room_title"] as String?;
        String? roomPrice = json["room_price"] as String?;
        String? roomProvince = json["room_province"] as String?;
        String? roomState = json["room_state"] as String?;

        List<String> parsedImages = [];
        if (roomRaw is Map) {
            roomId = roomRaw["id"] as int?;
            roomTitle ??= roomRaw["title"]?.toString();
            roomPrice ??= roomRaw["price"]?.toString();
            roomProvince ??= roomRaw["province"]?.toString();
            roomState ??= roomRaw["state"]?.toString();
            
            if (roomRaw["images"] != null && roomRaw["images"] is List) {
                for (var img in roomRaw["images"]) {
                    if (img is Map && img["image"] != null) {
                        String url = img["image"].toString();
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
        } else {
            roomId = roomRaw is int ? roomRaw : int.tryParse(roomRaw?.toString() ?? '');
        }

        final tenantRaw = json["tenant"];
        String? tenantId;
        String? tenantName = json["tenant_name"] as String?;
        if (tenantRaw is Map) {
            tenantId = tenantRaw["id"]?.toString();
            tenantName ??= tenantRaw["username"]?.toString() ?? tenantRaw["first_name"]?.toString();
        } else {
            tenantId = tenantRaw?.toString();
        }

        final landlordRaw = json["landlord"];
        String? landlordId = json["landlord_id"]?.toString();
        String? landlordName = json["landlord_name"] as String?;
        if (landlordRaw is Map) {
            landlordId ??= landlordRaw["id"]?.toString();
            landlordName ??= landlordRaw["username"]?.toString() ?? landlordRaw["first_name"]?.toString();
        }

        return Result(
            id: json["id"] as int?,
            status: json["status"] as String?,
            createdAt: DateTime.tryParse(json["created_at"] as String? ?? ""),
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
            tenantUser: (json["tenant"] is Map)
                ? UserModel.fromJson(json["tenant"] as Map<String, dynamic>)
                : null,
            rentStartDate: json["rent_start_date"] as String?,
            bookedDate: json["booked_date"] as String?,
        );
    }

}
