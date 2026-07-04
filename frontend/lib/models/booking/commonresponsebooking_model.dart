class CommonResponseBookingModel {
    CommonResponseBookingModel({
        required this.message,
    });

    final String? message;

    factory CommonResponseBookingModel.fromJson(Map<String, dynamic> json){ 
        return CommonResponseBookingModel(
            message: json["message"],
        );
    }

}
