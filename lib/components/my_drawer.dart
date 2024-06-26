import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fp_recipemanager/components/my_drawer_tile.dart';
import 'package:fp_recipemanager/pages/category/category_page.dart';
import 'package:fp_recipemanager/pages/recipe/bookmarked_recipe_page.dart';
import 'package:fp_recipemanager/pages/recipe/my_recipe_page.dart';
import 'package:fp_recipemanager/pages/profile/user_profile_page.dart';
import 'package:fp_recipemanager/services/user_profile_service.dart';
import 'package:fp_recipemanager/models/user_profile.dart';

class MyDrawer extends StatefulWidget {
  MyDrawer({super.key});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final user = FirebaseAuth.instance.currentUser!;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> _checkAdminStatus() async {
    UserProfileService _firestoreService = UserProfileService();
    UserProfile? userProfile = await _firestoreService.getUserProfile(user.uid);
    if (userProfile != null && userProfile.isAdmin) {
      setState(() {
        isAdmin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: Column(
        children: [
          // App Logo
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: SvgPicture.asset(
              'images/fitchen_logo_00.svg',
              semanticsLabel: 'SVG Image',
              height: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Colors.white,
            ),
          ),

          // Home List Tile
          MyDrawerTile(text: "H O M E", icon: Icons.home, onTap: () => Navigator.pop(context)),
          // Settings List Tile
          MyDrawerTile(
              text: "P R O F I L E", icon: Icons.person, onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage(),),);
          }),
          MyDrawerTile(
              text: "M Y  R E C I P E S", icon: Icons.fastfood, onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyRecipePage(),),);
          }),
          MyDrawerTile(
              text: "B O O K M A R K S", icon: Icons.bookmark, onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookmarkedRecipesPage(),),);
          }),
          if (isAdmin)
            MyDrawerTile(
                text: "C A T E G O R I E S", icon: Icons.tag, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryPage(),),);
            }),
          const Spacer(),
          // Logout List Tile
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MyDrawerTile(text: "L O G O U T", icon: Icons.logout, onTap: signUserOut),
          ),
        ],
      ),
    );
  }
}
