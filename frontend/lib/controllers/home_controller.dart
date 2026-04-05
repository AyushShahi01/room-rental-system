import 'package:get/get.dart';
import '../models/property_model.dart';
import '../controllers/property_controller.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var featuredProperties = <PropertyModel>[].obs;
  var nearbyProperties = <PropertyModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProperties();
  }

  void loadProperties() {
    isLoading.value = true;

    final propCtrl = Get.find<PropertyController>();

    Future.delayed(const Duration(seconds: 1), () {
      if (propCtrl.propertyList.length >= 2) {
        featuredProperties.assignAll([propCtrl.propertyList[0]]);
        nearbyProperties.assignAll([propCtrl.propertyList[1]]);
      } else {
        featuredProperties.assignAll(propCtrl.propertyList);
        nearbyProperties.assignAll(propCtrl.propertyList);
      }
      isLoading.value = false;
    });
  }
}
