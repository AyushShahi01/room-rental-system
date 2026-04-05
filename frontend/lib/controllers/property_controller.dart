import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/property_model.dart';

class PropertyController extends GetxController {
  var propertyList = <PropertyModel>[].obs;

  var selectedProperty = Rxn<PropertyModel>();

  var pickedImagePath = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  void loadDummyData() {
    propertyList.value = [
      PropertyModel(
        id: '1',
        title: 'Spacious Single Room',
        price: 8000,
        location: 'Banepa near Nist college',
        imageUrl:
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        status: 'AVAILABLE',
        bedrooms: 1,
        bathrooms: 1,
        hasWifi: true,
      ),
      // PropertyModel(
      //   id: '2',
      //   title: 'Cozy Double Room',
      //   price: 12000,
      //   location: 'Koteshwor, Kathmandu',
      //   imageUrl:
      //       'https://unsplash.com/photos/a-living-room-filled-with-furniture-and-a-flat-screen-tv-nmKPgfIUYtM',
      //   status: 'AVAILABLE',
      //   bedrooms: 1,
      //   bathrooms: 1,
      //   hasWifi: true,
      // ),
      PropertyModel(
        id: '3',
        title: 'Modern Studio Apartment',
        price: 18000,
        location: 'Panauti, Kavre',
        imageUrl:
            'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af',
        status: 'AVAILABLE',
        bedrooms: 1,
        bathrooms: 1,
        hasWifi: true,
      ),
      PropertyModel(
        id: '4',
        title: 'Affordable Shared Room',
        price: 5500,
        location: 'Balkumari, Lalitpur',
        imageUrl: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5',
        status: 'AVAILABLE',
        bedrooms: 1,
        bathrooms: 1,
        hasWifi: true,
      ),
    ];
  }

  void selectProperty(PropertyModel property) {
    selectedProperty.value = property;
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      pickedImagePath.value = image.path;
    }
  }

  void clearImage() {
    pickedImagePath.value = "";
  }

  void addProperty({
    required String title,
    required String location,
    required int price,
    required int bedrooms,
    required int bathrooms,
    required bool hasWifi,
    String? localImagePath,
  }) {
    final newProp = PropertyModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      location: location,
      price: price,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      hasWifi: hasWifi,
      status: 'AVAILABLE',
      localImagePath: localImagePath,
    );
    propertyList.add(newProp);
  }

  void updatePrice(String id, int newPrice) {
    var index = propertyList.indexWhere((p) => p.id == id);
    if (index != -1) {
      propertyList[index].price = newPrice;
      propertyList.refresh();
    }
  }
}
