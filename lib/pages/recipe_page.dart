import 'package:flutter/material.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/pages/recipe_form_page.dart';
import 'package:fp_recipemanager/pages/recipe_detail_page.dart';
import 'package:fp_recipemanager/services/storage_service.dart';
import 'package:fp_recipemanager/services/category_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../models/category.dart';

class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final RecipeService _recipeService = RecipeService();
  final StorageService _storageService = StorageService();
  final UserProfileService _userProfileService = UserProfileService();
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  String _selectedCategoryId = 'all';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    _categoryService.getCategory().listen((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Manager'),
      ),
      body: Column(
        children: [
          // Chips for category filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('All'),
                  selected: _selectedCategoryId == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = 'all';
                    });
                  },
                ),
                ..._categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category.categoryName),
                      selected: _selectedCategoryId == category.categoryId,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = category.categoryId;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
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

                final recipes = snapshot.data ?? [];
                final filteredRecipes = _selectedCategoryId == 'all'
                    ? recipes
                    : recipes.where((recipe) => recipe.categoryId == _selectedCategoryId).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
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
                                size: 80,
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
                                size: 80,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                                    child: Container(
                                      color: Colors.grey,
                                      child: imageWidget,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipe.title,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      FutureBuilder<UserProfile?>(
                                        future: _userProfileService.getUserProfile(recipe.createdBy),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return Row(
                                              children: [
                                                Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(child: Icon(Icons.person, size: 20, color: Colors.white)),
                                                ),
                                                SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    'Loading...',
                                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                            return Row(
                                              children: [
                                                Icon(Icons.person, size: 20, color: Colors.grey),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Creator: Unknown',
                                                  style: TextStyle(fontSize: 12, color: Colors.red),
                                                ),
                                              ],
                                            );
                                          } else {
                                            UserProfile creatorProfile = snapshot.data!;
                                            return Row(
                                              children: [
                                                if (creatorProfile.profilePicturePath != null)
                                                  FutureBuilder<String?>(
                                                    future: _storageService.getDownloadURL(creatorProfile.profilePicturePath!),
                                                    builder: (context, profilePictureSnapshot) {
                                                      if (profilePictureSnapshot.connectionState == ConnectionState.waiting) {
                                                        return Container(
                                                          height: 20,
                                                          width: 20,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Center(child: Icon(Icons.person, size: 20, color: Colors.white)),
                                                        );
                                                      } else if (profilePictureSnapshot.hasError || !profilePictureSnapshot.hasData || profilePictureSnapshot.data == null) {
                                                        return Icon(Icons.person, size: 20, color: Colors.grey);
                                                      } else {
                                                        return ClipOval(
                                                          child: CachedNetworkImage(
                                                            imageUrl: profilePictureSnapshot.data!,
                                                            placeholder: (context, url) => CircularProgressIndicator(),
                                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                                            width: 20,
                                                            height: 20,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    creatorProfile.fullName ?? creatorProfile.email,
                                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                                    softWrap: true,
                                                    overflow: TextOverflow.visible,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        DateFormat('yyyy-MM-dd – kk:mm').format(recipe.createdTime),
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeFormPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
