import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fp_recipemanager/services/recipe_service.dart';
import 'package:fp_recipemanager/models/recipe.dart';
import 'package:fp_recipemanager/pages/add_recipe_page.dart';
import 'package:fp_recipemanager/pages/edit_recipe_page.dart';
import 'package:fp_recipemanager/pages/recipe_detail_page.dart';
import 'package:fp_recipemanager/services/storage_service.dart'; // Import the storage service
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:firebase_auth/firebase_auth.dart'; // Import for current user
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final RecipeService _recipeService = RecipeService();
  final StorageService _storageService = StorageService();
  final UserProfileService _userProfileService = UserProfileService();

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Manager'),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: _recipeService.getRecipes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final recipes = snapshot.data ?? [];

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 3 / 4, // Adjust the aspect ratio as needed
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return FutureBuilder<Uint8List?>(
                future: _storageService.getFile(recipe.imagePath),
                builder: (context, imageSnapshot) {
                  Widget imageWidget;
                  if (imageSnapshot.connectionState == ConnectionState.waiting) {
                    imageWidget = CircularProgressIndicator();
                  } else if (imageSnapshot.hasError || !imageSnapshot.hasData || imageSnapshot.data == null) {
                    imageWidget = Icon(Icons.fastfood, size: 80, color: Colors.grey);
                  } else {
                    imageWidget = Image.memory(
                      imageSnapshot.data!,
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
                                color: Colors.grey, // Ensure a background color is provided for placeholder
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
                                                  return Icon(Icons.person, size: 20, color: Colors.grey);
                                                } else {
                                                  return ClipRRect(
                                                    borderRadius: BorderRadius.circular(25.0), // Half of the size to make it a circle
                                                    child: Image.memory(
                                                      profilePictureSnapshot.data!,
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
                                              style: TextStyle(fontSize: 12, color: Colors.grey), // Smaller font size
                                              softWrap: true,
                                              overflow: TextOverflow.visible, // Allow wrapping to next line if text is too long
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipePage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
