class ForgotpasswordModel {
    ForgotpasswordModel({
        required this.success,
        required this.message,
    });

    final bool? success;
    final String? message;

    factory ForgotpasswordModel.fromJson(Map<String, dynamic> json){ 
        return ForgotpasswordModel(
            success: json["success"],
            message: json["message"],
        );
    }

}
