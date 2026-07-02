import 'landlord_model.dart';

class RoomRecommendationModel {
    RoomRecommendationModel({
        required this.count,
        required this.results,
    });

    final int? count;
    final List<Result> results;

    factory RoomRecommendationModel.fromJson(Map<String, dynamic> json){ 
        return RoomRecommendationModel(
            count: json["count"],
            results: json["results"] == null ? [] : List<Result>.from(json["results"]!.map((x) => Result.fromJson(x))),
        );
    }

}

class Result {
    Result({
        required this.room,
        required this.cosineSimilarity,
        required this.locationScore,
        required this.combinedScore,
    });

    final Room? room;
    final double? cosineSimilarity;
    final double? locationScore;
    final double? combinedScore;

    factory Result.fromJson(Map<String, dynamic> json){ 
        return Result(
            room: json["room"] == null ? null : Room.fromJson(json["room"]),
            cosineSimilarity: json["cosine_similarity"],
            locationScore: json["location_score"],
            combinedScore: json["combined_score"],
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
    final LandlordModel? landlord;

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
            landlord: json["landlord"] == null ? null : LandlordModel.fromJson(json["landlord"]),
        );
    }

}
