import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_recipemanager/model/recipe.dart';

class RecipeService {
  final CollectionReference _recipesCollection =
  FirebaseFirestore.instance.collection('recipes');

  Future<void> addRecipe(Recipe recipe) {
    return _recipesCollection.add(recipe.toMap());
  }

  Future<void> updateRecipe(Recipe recipe) {
    return _recipesCollection.doc(recipe.id).update(recipe.toMap());
  }

  Future<void> deleteRecipe(String id) {
    return _recipesCollection.doc(id).delete();
  }

  Stream<List<Recipe>> getRecipes() {
    return _recipesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data() as Map<String, dynamic>)
          ..id = doc.id;
      }).toList();
    });
  }
}
