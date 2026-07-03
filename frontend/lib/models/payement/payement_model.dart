class PaymentModel {
    PaymentModel({
        required this.id,
        required this.booking,
        required this.amount,
        required this.status,
        required this.paymentGateway,
        required this.transactionToken,
        required this.gatewayResponse,
        required this.createdAt,
    });

    final int? id;
    final Booking? booking;
    final String? amount;
    final String? status;
    final String? paymentGateway;
    final dynamic transactionToken;
    final dynamic gatewayResponse;
    final DateTime? createdAt;

    factory PaymentModel.fromJson(Map<String, dynamic> json){ 
        return PaymentModel(
            id: json["id"],
            booking: json["booking"] == null ? null : Booking.fromJson(json["booking"]),
            amount: json["amount"],
            status: json["status"],
            paymentGateway: json["payment_gateway"],
            transactionToken: json["transaction_token"],
            gatewayResponse: json["gateway_response"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
        );
    }

}

class Booking {
    Booking({
        required this.id,
        required this.tenant,
        required this.room,
        required this.status,
        required this.createdAt,
    });

    final int? id;
    final Tenant? tenant;
    final Room? room;
    final String? status;
    final DateTime? createdAt;

    factory Booking.fromJson(Map<String, dynamic> json){ 
        return Booking(
            id: json["id"],
            tenant: json["tenant"] == null ? null : Tenant.fromJson(json["tenant"]),
            room: json["room"] == null ? null : Room.fromJson(json["room"]),
            status: json["status"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
        );
    }

}

class Room {
    Room({
        required this.id,
        required this.images,
        required this.title,
        required this.description,
        required this.price,
        required this.province,
        required this.state,
        required this.wardNumber,
        required this.furnishedStatus,
        required this.areaSqft,
        required this.securityDeposit,
        required this.maintenanceCharges,
        required this.hasWifi,
        required this.hasAc,
        required this.hasAttachedBathroom,
        required this.parkingAvailable,
        required this.foodAvailable,
        required this.genderPreference,
        required this.waterSupplyAvailable,
        required this.wasteCollectionAvailable,
        required this.isAvailable,
        required this.latitude,
        required this.longitude,
        required this.createdAt,
        required this.updatedAt,
        required this.landlord,
    });

    final int? id;
    final List<dynamic> images;
    final String? title;
    final String? description;
    final String? price;
    final String? province;
    final String? state;
    final int? wardNumber;
    final bool? furnishedStatus;
    final int? areaSqft;
    final String? securityDeposit;
    final String? maintenanceCharges;
    final bool? hasWifi;
    final bool? hasAc;
    final bool? hasAttachedBathroom;
    final bool? parkingAvailable;
    final bool? foodAvailable;
    final String? genderPreference;
    final bool? waterSupplyAvailable;
    final bool? wasteCollectionAvailable;
    final bool? isAvailable;
    final dynamic latitude;
    final dynamic longitude;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final Tenant? landlord;

    factory Room.fromJson(Map<String, dynamic> json){ 
        return Room(
            id: json["id"],
            images: json["images"] == null ? [] : List<dynamic>.from(json["images"]!.map((x) => x)),
            title: json["title"],
            description: json["description"],
            price: json["price"],
            province: json["province"],
            state: json["state"],
            wardNumber: json["ward_number"],
            furnishedStatus: json["furnished_status"],
            areaSqft: json["area_sqft"],
            securityDeposit: json["security_deposit"],
            maintenanceCharges: json["maintenance_charges"],
            hasWifi: json["has_wifi"],
            hasAc: json["has_ac"],
            hasAttachedBathroom: json["has_attached_bathroom"],
            parkingAvailable: json["parking_available"],
            foodAvailable: json["food_available"],
            genderPreference: json["gender_preference"],
            waterSupplyAvailable: json["water_supply_available"],
            wasteCollectionAvailable: json["waste_collection_available"],
            isAvailable: json["is_available"],
            latitude: json["latitude"],
            longitude: json["longitude"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
            landlord: json["landlord"] == null ? null : Tenant.fromJson(json["landlord"]),
        );
    }

}

class Tenant {
    Tenant({
        required this.id,
        required this.username,
        required this.email,
        required this.firstName,
        required this.lastName,
        required this.role,
        required this.tenantId,
        required this.landlordId,
        required this.province,
        required this.district,
        required this.city,
        required this.ward,
        required this.fcmToken,
        required this.profilePicture,
    });

    final String? id;
    final String? username;
    final String? email;
    final String? firstName;
    final String? lastName;
    final String? role;
    final String? tenantId;
    final String? landlordId;
    final String? province;
    final String? district;
    final String? city;
    final int? ward;
    final dynamic fcmToken;
    final dynamic profilePicture;

    factory Tenant.fromJson(Map<String, dynamic> json){ 
        return Tenant(
            id: json["id"],
            username: json["username"],
            email: json["email"],
            firstName: json["first_name"],
            lastName: json["last_name"],
            role: json["role"],
            tenantId: json["tenant_id"],
            landlordId: json["landlord_id"],
            province: json["province"],
            district: json["district"],
            city: json["city"],
            ward: json["ward"],
            fcmToken: json["fcm_token"],
            profilePicture: json["profile_picture"],
        );
    }

}
