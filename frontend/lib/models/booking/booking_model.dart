class BookingModel {
    BookingModel({
        required this.id,
        required this.status,
        required this.tenant,
        required this.room,
    });

    final int? id;
    final String? status;
    final String? tenant;
    final int? room;

    factory BookingModel.fromJson(Map<String, dynamic> json){ 
        return BookingModel(
            id: json["id"],
            status: json["status"],
            tenant: json["tenant"],
            room: json["room"],
        );
    }

}
