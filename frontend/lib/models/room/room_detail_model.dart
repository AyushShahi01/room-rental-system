import 'landlord_model.dart';
import '../../utils/dio_connection.dart';

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
        required this.latitude,
        required this.longitude,
        required this.createdAt,
        required this.updatedAt,
        required this.landlord,
        this.agreementPolicy,
        this.rentMode,
        this.fixedDurationType,
        this.fixedDurationValue,
        this.initialRent,
        this.incrementEvery,
        this.incrementType,
        this.increaseBy,
        this.houseRules,
        this.additionalDescription,
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
    final dynamic latitude;
    final dynamic longitude;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final LandlordModel? landlord;
    final String? agreementPolicy;
    final String? rentMode;
    final String? fixedDurationType;
    final int? fixedDurationValue;
    final String? initialRent;
    final String? incrementEvery;
    final String? incrementType;
    final String? increaseBy;
    final String? houseRules;
    final String? additionalDescription;

    factory RoomDetailModel.fromJson(Map<String, dynamic> json){ 
        return RoomDetailModel(
            id: json["id"],
            images: () {
              final imgs = json["images"] == null
                  ? <Image>[]
                  : List<Image>.from(json["images"]!.map((x) => Image.fromJson(x)))
                      .where((img) => img.image != null && img.image!.isNotEmpty)
                      .toList();
              imgs.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
              return imgs;
            }(),
            title: json["title"],
            description: json["description"],
            price: json["price"]?.toString(),
            province: json["province"],
            state: json["state"],
            wardNumber: json["ward_number"],
            furnishedStatus: json["furnished_status"],
            areaSqft: json["area_sqft"],
            securityDeposit: json["security_deposit"]?.toString(),
            maintenanceCharges: json["maintenance_charges"]?.toString(),
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
            agreementPolicy: json["agreement_policy"]?.toString(),
            rentMode: json["rent_mode"]?.toString(),
            fixedDurationType: json["fixed_duration_type"]?.toString(),
            fixedDurationValue: json["fixed_duration_value"] as int?,
            initialRent: json["initial_rent"]?.toString(),
            incrementEvery: json["increment_every"]?.toString(),
            incrementType: json["increment_type"]?.toString(),
            increaseBy: json["increase_by"]?.toString(),
            houseRules: json["house_rules"]?.toString(),
            additionalDescription: json["additional_description"]?.toString(),
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
        String? imgUrl = json["image"]?.toString();
        if (imgUrl != null) {
          if (imgUrl.startsWith('http://127.0.0.1') || imgUrl.startsWith('http://localhost')) {
            final uri = Uri.parse(imgUrl);
            imgUrl = DioConnection.baseDomain + uri.path;
          } else if (!imgUrl.startsWith('http')) {
            imgUrl = DioConnection.baseDomain + (imgUrl.startsWith('/') ? '' : '/') + imgUrl;
          }
        }
        return Image(
            id: json["id"],
            room: json["room"],
            image: imgUrl,
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
        );
    }

}
