class ProfileModel {
  String? profilePicture;
  String? address;
  String? occupation;
  String? dateOfBirth;
  String? createdAt;
  String? updatedAt;

  ProfileModel({
    this.profilePicture,
    this.address,
    this.occupation,
    this.dateOfBirth,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      profilePicture: json['profile_picture'],
      address: json['address'],
      occupation: json['occupation'],
      dateOfBirth: json['date_of_birth'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_picture': profilePicture,
      'address': address,
      'occupation': occupation,
      'date_of_birth': dateOfBirth,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class UserModel {
  String id;
  String email;
  String? fullName;
  String? phone;
  String role;
  bool isActive;
  bool isVerified;
  String? createdAt;
  ProfileModel? profile;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.isVerified,
    this.createdAt,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      phone: json['phone'],
      role: json['role'] ?? 'tenant',
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'],
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'is_verified': isVerified,
      'created_at': createdAt,
      'profile': profile?.toJson(),
    };
  }
}
