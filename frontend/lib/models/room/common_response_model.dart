class CommonResponseModel {
    CommonResponseModel({
        required this.message,
    });

    final String? message;

    factory CommonResponseModel.fromJson(Map<String, dynamic> json){ 
        return CommonResponseModel(
            message: json["message"],
        );
    }

}
