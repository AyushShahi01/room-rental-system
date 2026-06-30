class RefreshModel {
    RefreshModel({
        required this.access,
        required this.refresh,
    });

    final String? access;
    final String? refresh;

    factory RefreshModel.fromJson(Map<String, dynamic> json){ 
        return RefreshModel(
            access: json["access"],
            refresh: json["refresh"],
        );
    }

}
