class OtpverificationModel {
    OtpverificationModel({
        required this.success,
        required this.message,
    });

    final bool? success;
    final String? message;

    factory OtpverificationModel.fromJson(Map<String, dynamic> json){ 
        return OtpverificationModel(
            success: json["success"],
            message: json["message"],
        );
    }

}
