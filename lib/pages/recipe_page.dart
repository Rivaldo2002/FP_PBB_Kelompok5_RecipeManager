import 'package:flutter/material.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/model/recipe.dart';

class RecipePage extends StatelessWidget {
  final RecipeService _recipeService = RecipeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Manager'),
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

          final recipes = snapshot.data ?? [];

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                title: Text(recipe.title),
                subtitle: Text(recipe.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _showRecipeDialog(context, recipe: recipe);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _recipeService.deleteRecipe(recipe.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecipeDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showRecipeDialog(BuildContext context, {Recipe? recipe}) {
    final TextEditingController titleController =
    TextEditingController(text: recipe?.title ?? '');
    final TextEditingController descriptionController =
    TextEditingController(text: recipe?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipe == null ? 'Add Recipe' : 'Edit Recipe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRecipe = Recipe(
                id: recipe?.id ?? '',
                title: titleController.text,
                description: descriptionController.text,
              );

              if (recipe == null) {
                _recipeService.addRecipe(newRecipe);
              } else {
                _recipeService.updateRecipe(newRecipe);
              }

              Navigator.of(context).pop();
            },
            child: Text(recipe == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
