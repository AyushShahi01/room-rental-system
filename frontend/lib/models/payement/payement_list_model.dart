class PaymentListModel {
    PaymentListModel({
        required this.count,
        required this.next,
        required this.previous,
        required this.results,
    });

    final int? count;
    final dynamic next;
    final dynamic previous;
    final List<dynamic> results;

    factory PaymentListModel.fromJson(Map<String, dynamic> json){ 
        return PaymentListModel(
            count: json["count"],
            next: json["next"],
            previous: json["previous"],
            results: json["results"] == null ? [] : List<dynamic>.from(json["results"]!.map((x) => x)),
        );
    }

}
