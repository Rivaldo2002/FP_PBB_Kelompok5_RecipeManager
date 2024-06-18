import 'package:flutter/material.dart';
import 'package:fp_recipemanager/models/category.dart';
import 'package:fp_recipemanager/services/category_service.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;

  CategoryFormPage({this.category});

  @override
  _CategoryFormPageState createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final CategoryService _categoryService = CategoryService();
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.category != null;
    _titleController = TextEditingController(text: widget.category?.categoryName ?? '');
    _descriptionController = TextEditingController(text: widget.category?.description ?? '');
  }

  void _saveCategory() {
    if (isEditing) {
      final updatedCategory = Category(
        categoryId: widget.category!.categoryId,
        categoryName: _titleController.text,
        description: _descriptionController.text,
        createdTime: widget.category!.createdTime,
      );

      _categoryService.updateCategory(updatedCategory).then((_) {
        Navigator.of(context).pop();
      }).catchError((error) {
        // Handle error
        print('Failed to update category: $error');
      });
    } else {
      final newCategory = Category(
        categoryId: '',
        categoryName: _titleController.text,
        description: _descriptionController.text,
        createdTime: DateTime.now(),
      );

      _categoryService.addCategory(newCategory).then((_) {
        Navigator.of(context).pop();
      }).catchError((error) {
        // Handle error
        print('Failed to add category: $error');
      });
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      labelStyle: TextStyle(fontWeight: FontWeight.bold), // Bold label style
    );
  }

  String formatButtonText(String text) {
    return text.split('').join(' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Category Name'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: null,
                decoration: _inputDecoration('Category Description').copyWith(
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  child: Text(formatButtonText(isEditing ? 'Save' : 'Add Category')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Button background color
                    foregroundColor: Colors.white, // Button text color
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Same radius as in UserProfilePage
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
