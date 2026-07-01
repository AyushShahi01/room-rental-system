class BookingListModel {
    BookingListModel({
        required this.count,
        required this.next,
        required this.previous,
        required this.results,
    });

    final int? count;
    final String? next;
    final String? previous;
    final List<Result> results;

    factory BookingListModel.fromJson(Map<String, dynamic> json){ 
        return BookingListModel(
            count: json["count"],
            next: json["next"],
            previous: json["previous"],
            results: json["results"] == null ? [] : List<Result>.from(json["results"]!.map((x) => Result.fromJson(x))),
        );
    }

}

class Result {
    Result({
        required this.id,
        required this.status,
        required this.tenant,
        required this.room,
    });

    final int? id;
    final String? status;
    final String? tenant;
    final int? room;

    factory Result.fromJson(Map<String, dynamic> json){ 
        return Result(
            id: json["id"],
            status: json["status"],
            tenant: json["tenant"],
            room: json["room"],
        );
    }

}
