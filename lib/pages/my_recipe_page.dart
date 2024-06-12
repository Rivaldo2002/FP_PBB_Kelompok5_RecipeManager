import 'package:cached_network_image/cached_network_image.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/pages/add_recipe_page.dart';
import 'package:fp_recipemanager/pages/edit_recipe_page.dart';
import 'package:fp_recipemanager/pages/recipe_detail_page.dart';
import 'package:fp_recipemanager/services/storage_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyRecipePage extends StatefulWidget {
  @override
  _MyRecipePageState createState() => _MyRecipePageState();
}

class _MyRecipePageState extends State<MyRecipePage> {
  final RecipeService _recipeService = RecipeService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipes'),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: _recipeService.getRecipes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          User? currentUser = _auth.currentUser;
          if (currentUser == null) {
            return Center(child: Text('No user logged in.'));
          }

          final recipes = snapshot.data?.where((recipe) => recipe.createdBy == currentUser.uid).toList() ?? [];

          if (recipes.isEmpty) {
            return Center(child: Text('You have not created any recipes yet.'));
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return FutureBuilder<String?>(
                future: _storageService.getDownloadURL(recipe.imagePath),
                builder: (context, imageSnapshot) {
                  Widget imageWidget;
                  if (imageSnapshot.connectionState == ConnectionState.waiting) {
                    imageWidget = Container(
                      color: Colors.grey,
                      child: Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else if (imageSnapshot.hasError || !imageSnapshot.hasData || imageSnapshot.data == null) {
                    imageWidget = Container(
                      color: Colors.grey,
                      child: Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    imageWidget = CachedNetworkImage(
                      imageUrl: imageSnapshot.data!,
                      placeholder: (context, url) => Container(
                        color: Colors.grey,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey,
                        child: Center(
                          child: Icon(Icons.error),
                        ),
                      ),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  }
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(recipe: recipe),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              color: Colors.grey,
                              child: imageWidget,
                            ),
                          ),
                        ),
                      ),
                      title: Text(recipe.title),
                      subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(recipe.createdTime)),
                      trailing: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditRecipePage(recipe: recipe),
                                  ),
                                );
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _recipeService.deleteRecipe(recipe.recipeId);
                              },
                            ),
                          ],
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipePage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
