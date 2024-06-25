class Bookmark {
  String userId;
  String recipeId;
  DateTime timestamp;

  Bookmark({
    required this.userId,
    required this.recipeId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      userId: map['userId'],
      recipeId: map['recipeId'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
