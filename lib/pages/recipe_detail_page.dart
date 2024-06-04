import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/recipe_service.dart'; // Import service untuk Firebase
import '../model/recipe.dart';
import '../pages/edit_recipe_page.dart';
import '../pages/add_recipe_page.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(
              image: NetworkImage('${recipe.imageUrl}'),
              width: 250,
            ),
            Text(
              recipe.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Category: ${recipe.categoryId}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(recipe.description),
            // Tambahkan detail lain dari recipe sesuai kebutuhan
          ],
        ),
      ),
    );
  }
}
