class RoomDetailModel {
    RoomDetailModel({
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
        required this.createdAt,
        required this.updatedAt,
        required this.landlord,
    });

    final int? id;
    final List<Image> images;
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
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final String? landlord;

    factory RoomDetailModel.fromJson(Map<String, dynamic> json){ 
        return RoomDetailModel(
            id: json["id"],
            images: json["images"] == null ? [] : List<Image>.from(json["images"]!.map((x) => Image.fromJson(x))),
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
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
            landlord: json["landlord"],
        );
    }

}

class Image {
    Image({
        required this.id,
        required this.room,
        required this.image,
        required this.createdAt,
    });

    final int? id;
    final int? room;
    final String? image;
    final DateTime? createdAt;

    factory Image.fromJson(Map<String, dynamic> json){ 
        return Image(
            id: json["id"],
            room: json["room"],
            image: json["image"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
        );
    }

}
