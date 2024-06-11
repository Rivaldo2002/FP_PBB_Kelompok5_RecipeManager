import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart'; // Import for current user
import '../services/recipe_service.dart';
import '../models/recipe.dart';
import '../pages/edit_recipe_page.dart';
import '../services/storage_service.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  final StorageService _storageService = StorageService();
  final UserProfileService _userProfileService = UserProfileService();

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
                    builder: (context) => EditRecipePage(recipe: recipe),
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
            FutureBuilder<Uint8List?>(
              future: _storageService.getFile(recipe.imagePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width, // Make it square
                      color: Colors.grey,
                      child: Icon(Icons.fastfood, size: 100, color: Colors.white),
                    ),
                  );
                } else {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.memory(
                      snapshot.data!,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width, // Make it square
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
            Text(
              'Category: ${recipe.categoryId}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            FutureBuilder<UserProfile?>(
              future: _userProfileService.getUserProfile(recipe.createdBy),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return Text(
                    'Creator: Unknown',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  );
                } else {
                  UserProfile creatorProfile = snapshot.data!;
                  return Row(
                    children: [
                      if (creatorProfile.profilePicturePath != null)
                        FutureBuilder<Uint8List?>(
                          future: _storageService.getFile(creatorProfile.profilePicturePath!),
                          builder: (context, profilePictureSnapshot) {
                            if (profilePictureSnapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (profilePictureSnapshot.hasError || !profilePictureSnapshot.hasData || profilePictureSnapshot.data == null) {
                              return Icon(Icons.person, size: 50, color: Colors.grey);
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(25.0), // Half of the size to make it a circle
                                child: Image.memory(
                                  profilePictureSnapshot.data!,
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
