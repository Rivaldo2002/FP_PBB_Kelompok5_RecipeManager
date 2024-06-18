import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/pages/recipe/recipe_form_page.dart';
import 'package:fp_recipemanager/pages/recipe/recipe_detail_page.dart';
import 'package:fp_recipemanager/services/storage_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipemanager/services/category_service.dart';
import 'package:fp_recipemanager/models/category.dart';

class MyRecipePage extends StatefulWidget {
  @override
  _MyRecipePageState createState() => _MyRecipePageState();
}

class _MyRecipePageState extends State<MyRecipePage> {
  final RecipeService _recipeService = RecipeService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CategoryService _categoryService = CategoryService();

  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  String _selectedCategoryId = 'all';
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    _categoryService.getCategory().listen((categories) {
      setState(() {
        _categories = [Category(categoryId: 'all', categoryName: 'All', description: '', createdTime: DateTime.now()), ...categories];
      });
    });
  }

  String formatButtonText(String text) {
    return text.split('').join(' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Container(
            height: 40,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search My Recipes',
                hintStyle: TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: Colors.black),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecipeFormPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(formatButtonText("Add Recipe")),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    underline: SizedBox(),
                    items: _categories.map((Category category) {
                      return DropdownMenuItem<String>(
                        value: category.categoryId,
                        child: Text(category.categoryName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<Recipe>>(
                stream: _recipeService.getRecipes(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  User? currentUser = _auth.currentUser;
                  if (currentUser == null) {
                    return Center(child: Text('No user logged in.'));
                  }

                  final recipes = snapshot.data?.where((recipe) {
                    final matchesUser = recipe.createdBy == currentUser.uid;
                    final matchesQuery = recipe.title.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesCategory = _selectedCategoryId == 'all' || recipe.categoryId == _selectedCategoryId;
                    return matchesUser && matchesQuery && matchesCategory;
                  }).toList() ?? [];

                  if (recipes.isEmpty) {
                    return Center(child: Text('You have not created any recipes yet.'));
                  }

                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return FutureBuilder<String?>(
                        future: _storageService.getDownloadURL(recipe.imagePath),
                        builder: (context, imageSnapshot) {
                          Widget imageWidget;
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            imageWidget = Container(
                              color: Colors.grey,
                              child: Center(
                                child: Icon(
                                  Icons.fastfood,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          } else if (imageSnapshot.hasError || !imageSnapshot.hasData || imageSnapshot.data == null) {
                            imageWidget = Container(
                              color: Colors.grey,
                              child: Center(
                                child: Icon(
                                  Icons.fastfood,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          } else {
                            imageWidget = CachedNetworkImage(
                              imageUrl: imageSnapshot.data!,
                              placeholder: (context, url) => Container(
                                color: Colors.grey,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey,
                                child: Center(
                                  child: Icon(Icons.error),
                                ),
                              ),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            );
                          }
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailPage(recipe: recipe),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey,
                                        child: imageWidget,
                                      ),
                                    ),
                                    SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recipe.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            DateFormat('yyyy-MM-dd – kk:mm').format(recipe.createdTime),
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14.0,
                                            ),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () async {
                                            bool? result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => RecipeFormPage(recipe: recipe),
                                              ),
                                            );
                                            if (result == true) {
                                              setState(() {});
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            _recipeService.deleteRecipe(recipe.recipeId);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
