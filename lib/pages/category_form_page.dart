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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Category Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              maxLines: null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCategory,
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
