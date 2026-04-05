class PropertyModel {
  final String id;
  final String title;
  final String location;
  int price;
  final String? imageUrl;
  final String? localImagePath;
  final String status;
  final int bedrooms;
  final int bathrooms;
  final bool hasWifi;

  PropertyModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    this.imageUrl,
    this.localImagePath,
    required this.status,
    required this.bedrooms,
    required this.bathrooms,
    required this.hasWifi,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      price: json['price'] ?? 0,
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'AVAILABLE',
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      hasWifi: json['hasWifi'] ?? false,
    );
  }
}
