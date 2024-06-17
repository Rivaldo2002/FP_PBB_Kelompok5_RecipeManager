import 'package:flutter/material.dart';
import 'package:fp_recipemanager/model/category.dart';
import 'package:fp_recipemanager/services/category_service.dart';


class CategoryPages extends StatelessWidget {
  final CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Category'),
      ),
      body: StreamBuilder<List<category>>(
        stream: _categoryService.getCategory(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final category = snapshot.data ?? [];

          return ListView.builder(
            itemCount: category.length,
            itemBuilder: (context, index) {
              final recipe = category[index];
              return ListTile(
                title: Text(recipe.categoryname),
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
                        _categoryService.deleteCategory(recipe.id);
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

  void _showRecipeDialog(BuildContext context, {category? recipe}) {
    final TextEditingController titleController =
    TextEditingController(text: recipe?.categoryname ?? '');
    final TextEditingController descriptionController =
    TextEditingController(text: recipe?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipe == null ? 'Add Recipe Catergory' : 'Edit Recipe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Category Description'),
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
              final newRecipe = category(
                id: recipe?.id ?? '',
                categoryname: titleController.text,
                description: descriptionController.text,
              );

              if (recipe == null) {
                _categoryService.addCategory(newRecipe);
              } else {
                _categoryService.updateCategory(newRecipe);
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
