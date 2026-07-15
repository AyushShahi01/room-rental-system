import '../../utils/dio_connection.dart';

class UserModel {
    UserModel({
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
        this.profilePicture,
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
    final String? profilePicture;

    String get displayName {
        final fName = firstName ?? '';
        final lName = lastName ?? '';
        final fullName = '$fName $lName'.trim();
        return fullName.isNotEmpty ? fullName : (username ?? id ?? 'User');
    }

    String? get absoluteProfilePictureUrl {
        if (profilePicture == null || profilePicture!.isEmpty) return null;
        String url = profilePicture!;
        if (url.startsWith('http://127.0.0.1') || url.startsWith('http://localhost')) {
            final uri = Uri.parse(url);
            return DioConnection.baseDomain + uri.path;
        }
        if (url.startsWith('http://') || url.startsWith('https://')) {
            return url;
        }
        final base = DioConnection.baseDomain;
        if (url.startsWith('/')) {
            return '$base$url';
        }
        return '$base/$url';
    }

    factory UserModel.fromJson(Map<String, dynamic> json){ 
        return UserModel(
            id: json["id"]?.toString(),
            username: json["username"]?.toString(),
            email: json["email"]?.toString(),
            firstName: json["first_name"]?.toString(),
            lastName: json["last_name"]?.toString(),
            role: json["role"]?.toString(),
            tenantId: json["tenant_id"]?.toString(),
            landlordId: json["landlord_id"]?.toString(),
            province: json["province"]?.toString(),
            district: json["district"]?.toString(),
            city: json["city"]?.toString(),
            ward: json["ward"] is int ? json["ward"] as int : int.tryParse(json["ward"]?.toString() ?? ''),
            profilePicture: json["profile_picture"]?.toString(),
        );
    }

}

