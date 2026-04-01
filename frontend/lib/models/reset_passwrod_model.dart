class ResetPasswordModel {
    ResetPasswordModel({
        required this.success,
        required this.message,
    });

    final bool? success;
    final String? message;

    factory ResetPasswordModel.fromJson(Map<String, dynamic> json){ 
        return ResetPasswordModel(
            success: json["success"],
            message: json["message"],
        );
    }

}
