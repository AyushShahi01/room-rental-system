class TenantDashModel {
    TenantDashModel({
        required this.message,
    });

    final String? message;

    factory TenantDashModel.fromJson(Map<String, dynamic> json){ 
        return TenantDashModel(
            message: json["message"],
        );
    }

}
