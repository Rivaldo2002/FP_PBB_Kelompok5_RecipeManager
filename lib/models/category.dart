class Category {
  String categoryId;
  String categoryName;
  String description;
  DateTime createdTime;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.createdTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
      'createdTime': createdTime.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      description: map['description'],
      createdTime: DateTime.parse(map['createdTime']),
    );
  }
}
