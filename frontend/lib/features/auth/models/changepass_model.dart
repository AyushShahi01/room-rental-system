class ChangePassModel {
    ChangePassModel({
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

    factory ChangePassModel.fromJson(Map<String, dynamic> json){ 
        return ChangePassModel(
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
        );
    }

}
