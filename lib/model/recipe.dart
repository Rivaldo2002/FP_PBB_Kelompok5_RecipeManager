class Recipe {
  String id;
  String imageUrl;
  String title;
  String description;
  String categoryId;
  // DateTime createdTime;


  Recipe({required this.id, required this.imageUrl, required this.title, required this.description, required this.categoryId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      // 'createdTime': createdTime,
      'categoryId' : categoryId,

    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      // createdTime: map['createdTime'] ?? '',
      categoryId: map['categoryId'] ?? '',
    );
  }
}
