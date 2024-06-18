import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_recipemanager/models/category.dart';

class CategoryService {
  final CollectionReference _categoryCollection =
  FirebaseFirestore.instance.collection('category');

  Future<void> addCategory(Category category) async {
    DocumentReference docRef = await _categoryCollection.add(category.toMap());
    await docRef.update({'categoryId': docRef.id});
  }

  Future<void> updateCategory(Category category) {
    return _categoryCollection.doc(category.categoryId).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) {
    return _categoryCollection.doc(categoryId).delete();
  }

  Stream<List<Category>> getCategory() {
    return _categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<Category?> getCategoryById(String categoryId) async {
    DocumentSnapshot doc = await _categoryCollection.doc(categoryId).get();
    if (doc.exists) {
      return Category.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
