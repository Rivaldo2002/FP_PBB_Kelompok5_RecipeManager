import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipemanager/models/bookmark.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';

class BookmarkService {
  final CollectionReference _bookmarksCollection = FirebaseFirestore.instance.collection('bookmarks');
  final RecipeService _recipeService = RecipeService();

  Future<void> addBookmark(String userId, String recipeId) async {
    final docRef = _bookmarksCollection.doc('$userId-$recipeId');
    final bookmark = Bookmark(
      userId: userId,
      recipeId: recipeId,
      timestamp: DateTime.now(),
    );
    await docRef.set(bookmark.toMap());
  }

  Future<void> removeBookmark(String userId, String recipeId) async {
    final docRef = _bookmarksCollection.doc('$userId-$recipeId');
    await docRef.delete();
  }

  Stream<List<Bookmark>> getBookmarks(String userId) {
    return _bookmarksCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Bookmark.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<bool> isBookmarked(String userId, String recipeId) async {
    final docRef = _bookmarksCollection.doc('$userId-$recipeId');
    final docSnapshot = await docRef.get();
    return docSnapshot.exists;
  }

  Stream<List<Recipe>> getBookmarkedRecipes(String userId) {
    return _bookmarksCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Recipe> recipes = [];
      for (var doc in snapshot.docs) {
        final bookmark = Bookmark.fromMap(doc.data() as Map<String, dynamic>);
        final recipe = await _recipeService.getRecipeById(bookmark.recipeId);
        if (recipe != null) {
          recipes.add(recipe);
        } else {
          // If the recipe doesn't exist, remove the bookmark
          await removeBookmark(userId, bookmark.recipeId);
        }
      }
      return recipes;
    });
  }
}
