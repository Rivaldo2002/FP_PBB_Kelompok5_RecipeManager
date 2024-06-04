import 'package:flutter/material.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/model/recipe.dart';

class EditRecipePage extends StatelessWidget {
  final Recipe recipe;
  final TextEditingController imageUrlController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController categoryController;

  final RecipeService _recipeService = RecipeService();

  EditRecipePage({Key? key, required this.recipe})
      : imageUrlController = TextEditingController(text: recipe.imageUrl),
        titleController = TextEditingController(text: recipe.title),
        descriptionController = TextEditingController(text: recipe.description),
        categoryController = TextEditingController(text: recipe.categoryId),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(labelText: 'Image Url'),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category Id'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedRecipe = Recipe(
                  id: recipe.id,
                  imageUrl: imageUrlController.text,
                  title: titleController.text,
                  description: descriptionController.text,
                  categoryId: categoryController.text,
                  // createdTime: recipe.createdTime,

                );
                _recipeService.updateRecipe(updatedRecipe);
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
