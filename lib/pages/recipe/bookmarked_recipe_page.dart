import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/pages/recipe/recipe_detail_page.dart';
import 'package:fp_recipemanager/services/storage_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fp_recipemanager/models/category.dart';
import 'package:fp_recipemanager/services/category_service.dart';
import 'package:fp_recipemanager/models/user_profile.dart';
import 'package:fp_recipemanager/services/user_profile_service.dart';
import 'package:intl/intl.dart';
import 'package:fp_recipemanager/services/bookmark_service.dart';
import 'package:provider/provider.dart';

import '../../components/bookmark_button.dart';

class BookmarkedRecipesPage extends StatefulWidget {
  @override
  _BookmarkedRecipesPageState createState() => _BookmarkedRecipesPageState();
}

class _BookmarkedRecipesPageState extends State<BookmarkedRecipesPage> {
  final RecipeService _recipeService = RecipeService();
  final StorageService _storageService = StorageService();
  final CategoryService _categoryService = CategoryService();
  final UserProfileService _userProfileService = UserProfileService();
  final BookmarkService _bookmarkService = BookmarkService();

  String _searchQuery = '';
  String _selectedCategoryId = 'all';
  TextEditingController _searchController = TextEditingController();
  List<Category> _categories = [];

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

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.black54),
      prefixIcon: Icon(Icons.search, color: Colors.black54),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.white, width: 0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.white, width: 0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.white, width: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Container(
            height: 40,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Bookmarked Recipes',
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
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
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
                  SizedBox(width: 8),
                  ..._categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
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
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Recipe>>(
                stream: _bookmarkService.getBookmarkedRecipes(currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final recipes = snapshot.data ?? [];

                  // Filter recipes based on search query and selected category
                  final filteredRecipes = recipes.where((recipe) {
                    final matchesCategory = _selectedCategoryId == 'all' ||
                        (recipe.categoryId == null &&
                            _selectedCategoryId == 'all') ||
                        recipe.categoryId == _selectedCategoryId;
                    final matchesQuery = recipe.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                    return matchesCategory && matchesQuery;
                  }).toList();

                  if (filteredRecipes.isEmpty) {
                    return Center(child: Text('No bookmarked recipes found'));
                  }

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
                          if (imageSnapshot.connectionState ==
                              ConnectionState.waiting) {
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
                          } else if (imageSnapshot.hasError ||
                              !imageSnapshot.hasData ||
                              imageSnapshot.data == null) {
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
                                  builder: (context) =>
                                      RecipeDetailPage(recipe: recipe),
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
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(8.0)),
                                          child: Container(
                                            color: Colors.grey,
                                            child: imageWidget,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: BookmarkButton(
                                            recipeId: recipe.recipeId,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.title,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 4),
                                        FutureBuilder<UserProfile?>(
                                          future: _userProfileService
                                              .getUserProfile(recipe.createdBy),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Row(
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                        child: Icon(
                                                            Icons.person,
                                                            size: 20,
                                                            color:
                                                            Colors.white)),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Loading...',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              );
                                            } else if (snapshot.hasError ||
                                                !snapshot.hasData ||
                                                snapshot.data == null) {
                                              return Row(
                                                children: [
                                                  Icon(Icons.person,
                                                      size: 20,
                                                      color: Colors.grey),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Creator: Unknown',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              UserProfile creatorProfile =
                                              snapshot.data!;
                                              return Row(
                                                children: [
                                                  if (creatorProfile
                                                      .profilePicturePath !=
                                                      null)
                                                    FutureBuilder<String?>(
                                                      future: _storageService
                                                          .getDownloadURL(
                                                          creatorProfile
                                                              .profilePicturePath!),
                                                      builder: (context,
                                                          profilePictureSnapshot) {
                                                        if (profilePictureSnapshot
                                                            .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Container(
                                                            height: 20,
                                                            width: 20,
                                                            decoration:
                                                            BoxDecoration(
                                                              color:
                                                              Colors.grey,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .person,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .white)),
                                                          );
                                                        } else if (profilePictureSnapshot
                                                            .hasError ||
                                                            !profilePictureSnapshot
                                                                .hasData ||
                                                            profilePictureSnapshot
                                                                .data ==
                                                                null) {
                                                          return Icon(
                                                              Icons.person,
                                                              size: 20,
                                                              color:
                                                              Colors.grey);
                                                        } else {
                                                          return ClipOval(
                                                            child:
                                                            CachedNetworkImage(
                                                              imageUrl:
                                                              profilePictureSnapshot
                                                                  .data!,
                                                              placeholder: (context,
                                                                  url) =>
                                                                  CircularProgressIndicator(),
                                                              errorWidget: (context,
                                                                  url,
                                                                  error) =>
                                                                  Icon(Icons
                                                                      .error),
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
                                                      creatorProfile.fullName ??
                                                          creatorProfile.email,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey),
                                                      softWrap: true,
                                                      overflow:
                                                      TextOverflow.visible,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          DateFormat('yyyy-MM-dd – kk:mm')
                                              .format(recipe.createdTime),
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
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
      ),
    );
  }
}
