import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/components/recipe_image.dart';
import 'package:fp_recipemanager/models/category.dart';
import 'package:fp_recipemanager/services/category_service.dart';

class RecipeFormPage extends StatefulWidget {
  final Recipe? recipe;

  RecipeFormPage({Key? key, this.recipe}) : super(key: key);

  @override
  _RecipeFormPageState createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final RecipeService _recipeService = RecipeService();
  final CategoryService _categoryService = CategoryService();
  final _formKey = GlobalKey<FormState>();

  String? _imagePath;
  String? _recipeId;
  String? _selectedCategoryId;
  List<Category> _categories = [];

  bool get isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      titleController.text = widget.recipe!.title;
      descriptionController.text = widget.recipe!.description;
      _imagePath = widget.recipe!.imagePath;
      _recipeId = widget.recipe!.recipeId;
      _selectedCategoryId = widget.recipe!.categoryId;
    } else {
      _recipeId = _recipeService.generateNewRecipeId();
    }
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

  void _saveRecipe() async {
    if (_formKey.currentState?.validate() ?? false) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && _imagePath != null && _selectedCategoryId != null) {
        final recipe = Recipe(
          recipeId: _recipeId!,
          imagePath: _imagePath!,
          title: titleController.text,
          description: descriptionController.text,
          categoryId: _selectedCategoryId!,
          createdBy: isEditing ? widget.recipe!.createdBy : user.uid,
          createdTime: isEditing ? widget.recipe!.createdTime : DateTime.now(),
        );

        if (isEditing) {
          await _recipeService.updateRecipe(recipe);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Recipe updated successfully'),
            ),
          );
        } else {
          await _recipeService.addRecipe(recipe);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Recipe added successfully'),
            ),
          );
        }

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You need to be signed in, have an image, and select a category'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recipe' : 'Add Recipe'),
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
                  recipeId: _recipeId!,
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
                  onPressed: _saveRecipe,
                  child: Text(isEditing ? 'Save Changes' : 'Add Recipe'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
