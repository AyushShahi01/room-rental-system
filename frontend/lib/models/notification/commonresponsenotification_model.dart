class CommonResponseNotificationModel {
    CommonResponseNotificationModel({
        required this.message,
    });

    final String? message;

    factory CommonResponseNotificationModel.fromJson(Map<String, dynamic> json){ 
        return CommonResponseNotificationModel(
            message: json["message"],
        );
    }

}
