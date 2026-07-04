class RoomLocationModel {
  RoomLocationModel({
    required this.id,
    required this.title,
    required this.price,
    required this.province,
    required this.state,
    required this.wardNumber,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String title;
  final String price;
  final String province;
  final String state;
  final int wardNumber;
  final bool isAvailable;
  final double latitude;
  final double longitude;

  factory RoomLocationModel.fromJson(Map<String, dynamic> json) {
    return RoomLocationModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      wardNumber: json['ward_number'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? false,
      latitude: double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}
