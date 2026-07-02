class NotificationListModel {
    NotificationListModel({
        required this.count,
        required this.next,
        required this.previous,
        required this.results,
    });

    final int? count;
    final String? next;
    final String? previous;
    final List<Result> results;

    

    factory NotificationListModel.fromJson(Map<String, dynamic> json){ 
        return NotificationListModel(
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
        required this.user,
        required this.content,
        required this.isRead,
        required this.createdAt,
    });

    final int? id;
    final String? user;
    final String? content;
    final bool? isRead;
    final DateTime? createdAt;

    factory Result.fromJson(Map<String, dynamic> json){ 
        return Result(
            id: json["id"],
            user: json["user"]?.toString(),
            content: json["content"],
            isRead: json["is_read"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
        );
    }

}
