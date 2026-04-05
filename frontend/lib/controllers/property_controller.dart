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
        location: 'Baneshwor, Kathmandu',
        imageUrl:
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        status: 'AVAILABLE',
        bedrooms: 1,
        bathrooms: 1,
        hasWifi: true,
      ),
      PropertyModel(
        id: '2',
        title: 'Cozy Double Room',
        price: 12000,
        location: 'Koteshwor, Kathmandu',
        imageUrl:
            'https://images.unsplash.com/photo-1502672260266-1c1de24244e3',
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
