class category{
  String id;
  String categoryname;
  String description;

  category({
    required this.id,
    required this.categoryname,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'categoryname': categoryname,
      'description': description,
    };
  }
  factory category.fromMap(Map<String, dynamic> map) {
    return category(
      id: map['id'],
      categoryname: map['categoryname'],
      description: map['description'],
    );
  }
}