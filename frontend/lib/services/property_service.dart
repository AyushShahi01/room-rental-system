import '../models/property_model.dart';
import 'package:get/get.dart';

class PropertyService extends GetxService {
  Future<List<PropertyModel>> getFeaturedProperties() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return [
      PropertyModel(
        id: '1',
        title: 'Modern Studio Apartment',
        location: 'Downtown, Tech Park',
        price: 15000,
        imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        status: 'AVAILABLE',
        bedrooms: 1,
        bathrooms: 1,
        hasWifi: true,
      ),
      PropertyModel(
        id: '2',
        title: 'Cozy 2BHK Flat',
        location: 'Avenu Street, Uptown',
        price: 25000,
        imageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
        status: 'FAST FILLING',
        bedrooms: 2,
        bathrooms: 1,
        hasWifi: true,
      ),
      PropertyModel(
        id: '3',
        title: 'Luxury Penthouse',
        location: 'Skyline Build, City Center',
        price: 45000,
        imageUrl: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb',
        status: 'AVAILABLE',
        bedrooms: 3,
        bathrooms: 2,
        hasWifi: true,
      ),
    ];
  }

  Future<List<PropertyModel>> getNearbyProperties() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return [
      PropertyModel(
        id: '4',
        title: 'Sunny Small Room',
        location: 'Near Metro Station',
        price: 8000,
        imageUrl: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af',
        status: 'AVAILABLE',
        bedrooms: 1,
        bathrooms: 1,
        hasWifi: false,
      ),
      PropertyModel(
        id: '5',
        title: 'Shared Dorm Space',
        location: 'University Campus',
        price: 5000,
        imageUrl: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5',
        status: 'FAST FILLING',
        bedrooms: 1,
        bathrooms: 1,
        hasWifi: true,
      ),
      PropertyModel(
        id: '6',
        title: 'Student Single Room',
        location: 'College Road',
        price: 10000,
        imageUrl: 'https://images.unsplash.com/photo-1505691938895-1758d7feb511',
        status: 'AVAILABLE',
        bedrooms: 1,
        bathrooms: 1,
        hasWifi: true,
      ),
    ];
  }
}
