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
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(
                  labelText: 'Image Url',
                  labelStyle: TextStyle(fontWeight: FontWeight.w300),
              ),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(fontWeight: FontWeight.w300),
              ),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Description',
                floatingLabelBehavior: FloatingLabelBehavior.always, // Agar label selalu di atas
                labelStyle: TextStyle(fontWeight: FontWeight.w300), // Mengatur ketebalan font menjadi tipis
              ),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                  labelText: 'Category Id',
                labelStyle: TextStyle(fontWeight: FontWeight.w300),
              ),
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
    ),
    );
  }
}
