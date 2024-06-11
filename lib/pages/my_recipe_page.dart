import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/pages/add_recipe_page.dart';
import 'package:fp_recipemanager/pages/edit_recipe_page.dart';
import 'package:fp_recipemanager/pages/recipe_detail_page.dart';
import 'package:fp_recipemanager/services/storage_service.dart'; // Import the storage service
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:firebase_auth/firebase_auth.dart'; // Import for current user

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
              return FutureBuilder<Uint8List?>(
                future: _storageService.getFile(recipe.imagePath),
                builder: (context, imageSnapshot) {
                  Widget imageWidget;
                  if (imageSnapshot.connectionState == ConnectionState.waiting) {
                    imageWidget = CircularProgressIndicator();
                  } else if (imageSnapshot.hasError || !imageSnapshot.hasData || imageSnapshot.data == null) {
                    imageWidget = Icon(Icons.fastfood, size: 80, color: Colors.grey);
                  } else {
                    imageWidget = Image.memory(
                      imageSnapshot.data!,
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
                        padding: const EdgeInsets.only(left: 16.0), // Add padding to the left side
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              color: Colors.grey, // Ensure a background color is provided for placeholder
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
