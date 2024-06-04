import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/recipe_service.dart'; // Import service untuk Firebase
import '../model/recipe.dart';
import '../pages/edit_recipe_page.dart';
import '../pages/add_recipe_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  const RecipeDetailPage({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Recipe recipe;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshRecipe();
  }

  Future refreshRecipe() async {
    setState(() => isLoading = true);

    recipe = await RecipeService().getRecipeById(widget.recipeId); // Menggunakan service untuk mengambil data dari Firebase

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Image(
          //   image: NetworkImage('${recipe.cover}'),
          //   width: 250,
          // ),
          Text(
            recipe.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Text(
          //   DateFormat.yMMMd().format(recipe.createdTime),
          //   style: const TextStyle(color: Colors.white38),
          // ),
          const SizedBox(height: 8),
          Text(
            recipe.description,
            style:
            const TextStyle(color: Colors.white70, fontSize: 18),
          )
        ],
      ),
    ),
  );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EditRecipePage(recipe: recipe),
        ));

        refreshRecipe();
      });

  Widget deleteButton() => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () async {
      await RecipeService().deleteRecipe(widget.recipeId); // Menggunakan service untuk menghapus data dari Firebase

      Navigator.of(context).pop();
    },
  );
}

