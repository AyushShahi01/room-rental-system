class ErrorResponseModel {
  ErrorResponseModel({
    this.error,
    this.fcmToken,
    this.code,
  });

  final String? error;
  final List<String>? fcmToken;
  final List<String>? code;

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return ErrorResponseModel(
      error: json["error"],
      fcmToken: json["fcm_token"] == null
          ? null
          : List<String>.from(json["fcm_token"]),
      code: json["code"] == null
          ? null
          : List<String>.from(json["code"]),
    );
  }
}