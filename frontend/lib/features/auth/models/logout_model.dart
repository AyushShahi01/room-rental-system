class LogoutModel {
    LogoutModel({
        required this.message,
    });

    final String? message;

    factory LogoutModel.fromJson(Map<String, dynamic> json){ 
        return LogoutModel(
            message: json["message"],
        );
    }

}
