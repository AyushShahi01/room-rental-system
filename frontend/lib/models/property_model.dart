class PropertyModel {
  final String id;
  final String title;
  final String location;
  final int price;
  final String imageUrl;
  final String status; 
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

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    String imgUrl = '';
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      final img = json['images'][0];
      if (img is Map && img['image'] != null) {
        imgUrl = img['image'].toString();
        if (!imgUrl.startsWith('http')) {
          imgUrl = 'https://room-rental-system-f5x8.onrender.com' + imgUrl;
        }
      }
    }

    if (imgUrl.isEmpty) {
      imgUrl = 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?q=80&w=600&auto=format&fit=crop';
    }

    final String state = json['state']?.toString() ?? '';
    final String province = json['province']?.toString() ?? '';
    final String locationText = (state.isNotEmpty && province.isNotEmpty)
        ? '$state, $province'
        : (state.isNotEmpty ? state : (province.isNotEmpty ? province : 'Nepal'));

    int parsedPrice = 0;
    if (json['price'] != null) {
      parsedPrice = (double.tryParse(json['price'].toString()) ?? 0).toInt();
    }

    return PropertyModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      location: locationText,
      price: parsedPrice,
      imageUrl: imgUrl,
      status: (json['is_available'] ?? true) ? 'Available' : 'Unavailable',
      bedrooms: json['bedrooms'] ?? 1,
      bathrooms: (json['has_attached_bathroom'] ?? false) ? 1 : 0,
      hasWifi: json['has_wifi'] ?? false,
    );
  }
}
