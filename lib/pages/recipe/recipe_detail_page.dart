import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/pages/recipe/recipe_form_page.dart';
import 'package:fp_recipemanager/services/storage_service.dart';
import 'package:fp_recipemanager/services/user_profile_service.dart';
import 'package:fp_recipemanager/services/category_service.dart';
import 'package:fp_recipemanager/models/user_profile.dart';
import 'package:fp_recipemanager/models/category.dart';
import 'package:fp_recipemanager/components/bookmark_button.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  RecipeDetailPage({required this.recipe});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final StorageService _storageService = StorageService();
  final UserProfileService _userProfileService = UserProfileService();
  final CategoryService _categoryService = CategoryService();
  final RecipeService _recipeService = RecipeService();

  late Future<Recipe?> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _recipeService.getRecipeById(widget.recipe.recipeId);
  }

  void _refreshRecipe() {
    setState(() {
      _recipeFuture = _recipeService.getRecipeById(widget.recipe.recipeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<Recipe?>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(child: Text('Error loading recipe details')),
          );
        } else {
          final recipe = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(recipe.title),
              actions: [
                if (currentUser != null && recipe.createdBy == currentUser.uid)
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
                        _refreshRecipe();
                      }
                    },
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String?>(
                    future: _storageService.getDownloadURL(recipe.imagePath),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.width,
                                color: Colors.grey,
                                child: Center(
                                  child: Icon(
                                    Icons.fastfood,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ),
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
                        );
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.width,
                                color: Colors.grey,
                                child: Center(
                                  child: Icon(
                                    Icons.fastfood,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ),
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
                        );
                      } else {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: CachedNetworkImage(
                                imageUrl: snapshot.data!,
                                placeholder: (context, url) => Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.width,
                                  color: Colors.grey,
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.width,
                                  color: Colors.grey,
                                  child: Center(
                                    child: Icon(Icons.error),
                                  ),
                                ),
                                width: double.infinity,
                                height: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
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
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    recipe.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<Category?>(
                    future: recipe.categoryId != null ? _categoryService.getCategoryById(recipe.categoryId!) : Future.value(null),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Chip(label: Text('Loading...'));
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return Chip(
                          label: Text(
                            'General',
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      } else {
                        return Chip(label: Text(snapshot.data!.categoryName));
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<UserProfile?>(
                    future: _userProfileService.getUserProfile(recipe.createdBy),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Loading...',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                                Text(
                                  'Loading...',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return Row(
                          children: [
                            Icon(Icons.person, size: 30, color: Colors.grey),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Creator: Unknown',
                                  style: TextStyle(fontSize: 16, color: Colors.red),
                                ),
                                Text(
                                  'Date: Unknown',
                                  style: TextStyle(fontSize: 12, color: Colors.red),
                                ),
                              ],
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
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  } else if (profilePictureSnapshot.hasError || !profilePictureSnapshot.hasData || profilePictureSnapshot.data == null) {
                                    return Icon(Icons.person, size: 30, color: Colors.grey);
                                  } else {
                                    return ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: profilePictureSnapshot.data!,
                                        placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }
                                },
                              ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  creatorProfile.fullName ?? creatorProfile.email,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat('yyyy-MM-dd – kk:mm').format(recipe.createdTime),
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    recipe.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty) ...[
                    Text(
                      'Ingredients',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recipe.ingredients!.length,
                      itemBuilder: (context, index) {
                        String ingredient = recipe.ingredients!.keys.elementAt(index);
                        String? quantity = recipe.ingredients![ingredient];
                        return ListTile(
                          title: Text(ingredient),
                          subtitle: quantity != null ? Text(quantity) : null,
                        );
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                  Text(
                    'Steps',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  recipe.steps != null && recipe.steps!.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recipe.steps!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 15,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(recipe.steps![index]),
                      );
                    },
                  )
                      : Text(
                    'No steps available for this recipe.',
                    style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
