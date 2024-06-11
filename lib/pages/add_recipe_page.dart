import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/components/recipe_image.dart';

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  final RecipeService _recipeService = RecipeService();
  final _formKey = GlobalKey<FormState>();

  String? _imagePath;
  String _recipeId = ''; // To store the generated recipeId

  @override
  void initState() {
    super.initState();
    // Generate a new recipe ID here
    _recipeId = _recipeService.generateNewRecipeId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add RecipeImage widget here
                RecipeImage(
                  recipeId: _recipeId, // Use the generated recipeId
                  onImagePathChanged: (path) {
                    setState(() {
                      _imagePath = path;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category Id',
                    labelStyle: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category Id is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null && _imagePath != null) {
                        final newRecipe = Recipe(
                          recipeId: _recipeId, // Use the generated recipeId
                          imagePath: _imagePath!,
                          title: titleController.text,
                          description: descriptionController.text,
                          categoryId: categoryController.text,
                          createdBy: user.uid,
                          createdTime: DateTime.now(),
                        );
                        await _recipeService.addRecipe(newRecipe);

                        // Show success snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Recipe added successfully'),
                          ),
                        );

                        Navigator.pop(context);
                      } else {
                        // Handle the case when the user is not signed in or imagePath is not set
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You need to be signed in and have an image to add a recipe'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Add Recipe'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
