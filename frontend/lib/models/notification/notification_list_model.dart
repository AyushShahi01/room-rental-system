class NotificationListModel {
    NotificationListModel({
        required this.count,
        required this.next,
        required this.previous,
        required this.results,
    });

    final int? count;
    final String? next;
    final dynamic previous;
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
        required this.content,
        required this.isRead,
        required this.createdAt,
        this.isDashboardActivity = false,
    });

    final int? id;
    final String? content;
    final bool? isRead;
    final DateTime? createdAt;
    /// Dashboard activity is display-only: it does not have a notification API id.
    final bool isDashboardActivity;

    factory Result.fromJson(Map<String, dynamic> json){ 
        return Result(
            id: json["id"],
            content: json["content"],
            isRead: json["is_read"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            isDashboardActivity: false,
        );
    }

}
