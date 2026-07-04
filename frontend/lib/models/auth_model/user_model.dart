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
        );
    }

}
