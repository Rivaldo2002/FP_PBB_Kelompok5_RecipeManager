import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../pages/recipe_form_page.dart'; // Updated import
import '../services/storage_service.dart';
import '../services/user_profile_service.dart';
import '../services/category_service.dart';
import '../models/user_profile.dart';
import '../models/category.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  final StorageService _storageService = StorageService();
  final UserProfileService _userProfileService = UserProfileService();
  final CategoryService _categoryService = CategoryService();

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          if (currentUser != null && recipe.createdBy == currentUser.uid)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeFormPage(recipe: recipe), // Updated to use RecipeFormPage
                  ),
                );
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
                  return ClipRRect(
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
                  );
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return ClipRRect(
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
                  );
                } else {
                  return ClipRRect(
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
              future: _categoryService.getCategoryById(recipe.categoryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Category: Loading...',
                    style: TextStyle(fontSize: 18),
                  );
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return Text(
                    'Category: Unknown',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  );
                } else {
                  return Text(
                    'Category: ${snapshot.data!.categoryName}',
                    style: TextStyle(fontSize: 18),
                  );
                }
              },
            ),
            SizedBox(height: 8),
            FutureBuilder<UserProfile?>(
              future: _userProfileService.getUserProfile(recipe.createdBy),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Loading...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  );
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return Row(
                    children: [
                      Icon(Icons.person, size: 25, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Creator: Unknown',
                        style: TextStyle(fontSize: 16, color: Colors.red),
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
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            } else if (profilePictureSnapshot.hasError || !profilePictureSnapshot.hasData || profilePictureSnapshot.data == null) {
                              return Icon(Icons.person, size: 50, color: Colors.grey);
                            } else {
                              return ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: profilePictureSnapshot.data!,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                          },
                        ),
                      SizedBox(width: 8),
                      Text(
                        creatorProfile.fullName ?? creatorProfile.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 16),
            Text(
              'Created: ${DateFormat('yyyy-MM-dd – kk:mm').format(recipe.createdTime)}',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              recipe.description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
