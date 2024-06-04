import 'package:flutter/material.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/model/recipe.dart';

class AddRecipePage extends StatelessWidget{
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  final RecipeService _recipeService = RecipeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
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
                final newRecipe = Recipe(
                  id: '',
                  imageUrl: imageUrlController.text,
                  title: titleController.text,
                  description: descriptionController.text,
                  // createdTime: DateTime.now(),
                  categoryId: categoryController.text
                );
                _recipeService.addRecipe(newRecipe);
                Navigator.pop(context);
              },
              child: Text('Add Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
