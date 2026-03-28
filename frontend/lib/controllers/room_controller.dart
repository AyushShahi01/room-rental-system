import 'package:get/get.dart';
import '../models/room_model.dart';

class RoomController extends GetxController {
  // List of rooms (Dummy Data)
  var roomList = <RoomModel>[].obs;
  
  // Selected room for details
  var selectedRoom = Rxn<RoomModel>();

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  void loadDummyData() {
    roomList.value = [
      RoomModel(
        id: '1',
        title: 'Spacious Single Room',
        price: 8000.0,
        location: 'Baneshwor, Kathmandu',
        imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=500&q=80',
        isAvailable: true,
        description: 'A beautiful and spacious single room perfect for students.',
        ownerName: 'Ram Shrestha',
        ownerPhone: '9800000000',
        amenities: ['WiFi', 'Water', 'Electricity'],
      ),
      RoomModel(
        id: '2',
        title: 'Cozy Double Room',
        price: 12000.0,
        location: 'Koteshwor, Kathmandu',
        imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1de24244e3?w=500&q=80',
        isAvailable: true,
        description: 'Cozy double room with attached bathroom.',
        ownerName: 'Shyam Thapa',
        ownerPhone: '9811111111',
        amenities: ['WiFi', 'Attached Bathroom', 'Parking'],
      ),
    ];
  }

  void selectRoom(RoomModel room) {
    selectedRoom.value = room;
  }
}
