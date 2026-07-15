class CommonResponseAuthModel {
  final String message;

  CommonResponseAuthModel({
    required this.message,
  });

  factory CommonResponseAuthModel.fromJson(Map<String, dynamic> json) {
    return CommonResponseAuthModel(
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}