class RegisterModel {
  String? message;
  Tokens? tokens;
  User? user;

  RegisterModel({this.message, this.tokens, this.user});

  RegisterModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    tokens =
        json['tokens'] != null ? new Tokens.fromJson(json['tokens']) : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.tokens != null) {
      data['tokens'] = this.tokens!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class Tokens {
  String? refresh;
  String? access;

  Tokens({this.refresh, this.access});

  Tokens.fromJson(Map<String, dynamic> json) {
    refresh = json['refresh'];
    access = json['access'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['refresh'] = this.refresh;
    data['access'] = this.access;
    return data;
  }
}

class User {
  String? id;
  String? username;
  String? email;
  String? firstName;
  String? lastName;
  String? role;
  String? tenantId;
  String? landlordId;
  String? province;
  String? district;
  String? city;
  dynamic ward;

  User(
      {this.id,
      this.username,
      this.email,
      this.firstName,
      this.lastName,
      this.role,
      this.tenantId,
      this.landlordId,
      this.province,
      this.district,
      this.city,
      this.ward});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    role = json['role'];
    tenantId = json['tenant_id'];
    landlordId = json['landlord_id'];
    province = json['province'];
    district = json['district'];
    city = json['city'];
    ward = json['ward'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['role'] = this.role;
    data['tenant_id'] = this.tenantId;
    data['landlord_id'] = this.landlordId;
    data['province'] = this.province;
    data['district'] = this.district;
    data['city'] = this.city;
    data['ward'] = this.ward;
    return data;
  }
}