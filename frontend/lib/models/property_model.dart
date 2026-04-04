class PropertyModel {
  final String id;
  final String title;
  final String location;
  final int price;
  final String imageUrl;
  final String status; // "AVAILABLE", "FAST FILLING"
  final int bedrooms;
  final int bathrooms;
  final bool hasWifi;

  PropertyModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.bedrooms,
    required this.bathrooms,
    required this.hasWifi,
  });
}
