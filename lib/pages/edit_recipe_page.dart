import 'package:flutter/material.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipemanager/components/recipe_image.dart';

class EditRecipePage extends StatefulWidget {
  final Recipe recipe;

  EditRecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  _EditRecipePageState createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  final RecipeService _recipeService = RecipeService();
  final _formKey = GlobalKey<FormState>();

  String? _imagePath;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.recipe.title;
    descriptionController.text = widget.recipe.description;
    categoryController.text = widget.recipe.categoryId;
    _imagePath = widget.recipe.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Recipe'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RecipeImage(
                  recipeId: widget.recipe.recipeId,
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
                        final updatedRecipe = Recipe(
                          recipeId: widget.recipe.recipeId,
                          imagePath: _imagePath!,
                          title: titleController.text,
                          description: descriptionController.text,
                          categoryId: categoryController.text,
                          createdBy: widget.recipe.createdBy, // Retain the original creator
                          createdTime: widget.recipe.createdTime, // Retain the original creation time
                        );
                        await _recipeService.updateRecipe(updatedRecipe);

                        // Show success snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Recipe updated successfully'),
                          ),
                        );

                        Navigator.pop(context);
                      } else {
                        // Handle the case when the user is not signed in or imagePath is not set
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You need to be signed in and have an image to update the recipe'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
