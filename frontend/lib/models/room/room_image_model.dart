class RoomImageModel {
    RoomImageModel({
        required this.count,
        required this.next,
        required this.previous,
        required this.results,
    });

    final int? count;
    final String? next;
    final String? previous;
    final List<Result> results;

    factory RoomImageModel.fromJson(Map<String, dynamic> json){ 
        return RoomImageModel(
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
        required this.room,
        required this.image,
        required this.createdAt,
    });

    final int? id;
    final int? room;
    final String? image;
    final DateTime? createdAt;

    factory Result.fromJson(Map<String, dynamic> json){ 
        return Result(
            id: json["id"],
            room: json["room"],
            image: json["image"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
        );
    }

}
