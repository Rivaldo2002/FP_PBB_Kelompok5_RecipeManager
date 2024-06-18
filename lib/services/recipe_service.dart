import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeService {
  final CollectionReference _recipesCollection = FirebaseFirestore.instance.collection('recipes');

  String generateNewRecipeId() {
    return _recipesCollection.doc().id;
  }

  Future<void> addRecipe(Recipe recipe) {
    final docRef = _recipesCollection.doc(recipe.recipeId);
    return docRef.set(recipe.toMap());
  }

  Future<void> updateRecipe(Recipe recipe) {
    return _recipesCollection.doc(recipe.recipeId).update(recipe.toMap());
  }

  Future<void> deleteRecipe(String recipeId) {
    return _recipesCollection.doc(recipeId).delete();
  }

  Stream<List<Recipe>> getRecipes() {
    return _recipesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data() as Map<String, dynamic>)..recipeId = doc.id;
      }).toList();
    });
  }

  Stream<List<Recipe>> getRecipesByUser(String userId) {
    return _recipesCollection.where('createdBy', isEqualTo: userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Recipe.fromMap(doc.data() as Map<String, dynamic>)..recipeId = doc.id;
      }).toList();
    });
  }

  Future<Recipe> getRecipeById(String recipeId) async {
    DocumentSnapshot recipeDoc = await _recipesCollection.doc(recipeId).get();
    return Recipe.fromMap(recipeDoc.data() as Map<String, dynamic>)..recipeId = recipeDoc.id;
  }
}
