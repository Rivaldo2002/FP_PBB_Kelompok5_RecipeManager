class Recipe {
  String recipeId;
  String imagePath;
  String title;
  String description;
  List<String>? steps;
  String? categoryId; // Made optional
  String createdBy;
  DateTime createdTime;

  Recipe({
    required this.recipeId,
    required this.imagePath,
    required this.title,
    required this.description,
    this.steps,
    this.categoryId, // Made optional
    required this.createdBy,
    required this.createdTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'imagePath': imagePath,
      'title': title,
      'description': description,
      'steps': steps,
      'categoryId': categoryId,
      'createdBy': createdBy,
      'createdTime': createdTime.toIso8601String(),
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      recipeId: map['recipeId'] ?? '',
      imagePath: map['imagePath'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      steps: map['steps'] != null ? List<String>.from(map['steps']) : null,
      categoryId: map['categoryId'],
      createdBy: map['createdBy'] ?? '',
      createdTime: map['createdTime'] != null ? DateTime.parse(map['createdTime']) : DateTime.now(),
    );
  }
}
