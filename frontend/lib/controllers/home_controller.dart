import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';

class HomeController extends GetxController {
  final PropertyService _propertyService = Get.put(PropertyService());

  final mapCenter = const LatLng(51.509364, -0.128928).obs;
  final mapZoom = 13.0.obs;

  final RxList<PropertyModel> featuredProperties = <PropertyModel>[].obs;
  final RxList<PropertyModel> nearbyProperties = <PropertyModel>[].obs;
  final RxBool isLoading = true.obs;

  // Placeholder for map markers
  final List<LatLng> roomLocations = [
    const LatLng(51.509364, -0.128928),
    const LatLng(51.519364, -0.118928),
    const LatLng(51.500364, -0.138928),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    isLoading.value = true;
    try {
      final featured = await _propertyService.getFeaturedProperties();
      final nearby = await _propertyService.getNearbyProperties();
      featuredProperties.value = featured;
      nearbyProperties.value = nearby;
    } finally {
      isLoading.value = false;
    }
  }
}
