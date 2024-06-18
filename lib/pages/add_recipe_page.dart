import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/components/recipe_image.dart';
import 'package:fp_recipemanager/models/category.dart';
import 'package:fp_recipemanager/services/category_service.dart';

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final RecipeService _recipeService = RecipeService();
  final CategoryService _categoryService = CategoryService();
  final _formKey = GlobalKey<FormState>();

  String? _imagePath;
  String _recipeId = ''; // To store the generated recipeId
  String? _selectedCategoryId; // To store the selected categoryId
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _recipeId = _recipeService.generateNewRecipeId();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    _categoryService.getCategory().listen((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.w300),
    );
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
                RecipeImage(
                  recipeId: _recipeId,
                  onImagePathChanged: (path) {
                    setState(() {
                      _imagePath = path;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: titleController,
                  decoration: _inputDecoration('Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 10,
                  decoration: _inputDecoration('Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  items: _categories.map((Category category) {
                    return DropdownMenuItem<String>(
                      value: category.categoryId,
                      child: Text(category.categoryName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  decoration: _inputDecoration('Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null && _imagePath != null && _selectedCategoryId != null) {
                        final newRecipe = Recipe(
                          recipeId: _recipeId,
                          imagePath: _imagePath!,
                          title: titleController.text,
                          description: descriptionController.text,
                          categoryId: _selectedCategoryId!,
                          createdBy: user.uid,
                          createdTime: DateTime.now(),
                        );
                        await _recipeService.addRecipe(newRecipe);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Recipe added successfully'),
                          ),
                        );

                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You need to be signed in, have an image, and select a category to add a recipe'),
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
