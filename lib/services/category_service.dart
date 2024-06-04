import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_recipemanager/model/category.dart';

class CategoryService {
  final CollectionReference _categoryCollection =
  FirebaseFirestore.instance.collection('category');

  Future<void> addCategory(category recipe) {
    return _categoryCollection.add(recipe.toMap());
  }

  Future<void> updateCategory(category recipe) {
    return _categoryCollection.doc(recipe.id).update(recipe.toMap());
  }

  Future<void> deleteCategory(String id) {
    return _categoryCollection.doc(id).delete();
  }

  Stream<List<category>> getCategory() {
    return _categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return category.fromMap(doc.data() as Map<String, dynamic>)
          ..id = doc.id;
      }).toList();
    });
  }
}
