class LandlordDashModel {
    LandlordDashModel({
        required this.message,
    });

    final String? message;

    factory LandlordDashModel.fromJson(Map<String, dynamic> json){ 
        return LandlordDashModel(
            message: json["message"],
        );
    }

}
