class RoomModel {
  final String id;
  final String title;
  final double price;
  final String location;
  final String imageUrl;
  final bool isAvailable;
  final String description;
  final String ownerName;
  final String ownerPhone;
  final List<String> amenities;

  RoomModel({
    this.id = '',
    this.title = '',
    this.price = 0.0,
    this.location = '',
    this.imageUrl = '',
    this.isAvailable = false,
    this.description = '',
    this.ownerName = '',
    this.ownerPhone = '',
    this.amenities = const [],
  });
}
