class Recipe {
  String recipeId;
  String imagePath;
  String title;
  String description;
  List<String>? steps; // Include steps from his code
  String? categoryId; // Optional field
  String createdBy;
  DateTime createdTime;

  Recipe({
    required this.recipeId,
    required this.imagePath,
    required this.title,
    required this.description,
    this.steps, // Optional field
    this.categoryId, // Optional field
    required this.createdBy,
    required this.createdTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'imagePath': imagePath,
      'title': title,
      'description': description,
      'steps': steps, // Include steps in the map
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
      steps: map['steps'] != null ? List<String>.from(map['steps']) : null, // Parse steps
      categoryId: map['categoryId'],
      createdBy: map['createdBy'] ?? '',
      createdTime: map['createdTime'] != null ? DateTime.parse(map['createdTime']) : DateTime.now(),
    );
  }
}
