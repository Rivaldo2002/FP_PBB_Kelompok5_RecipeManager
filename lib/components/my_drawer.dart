import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fp_recipemanager/components/my_drawer_tile.dart';
import 'package:fp_recipemanager/pages/add_recipe_page.dart';
import 'package:fp_recipemanager/pages/my_recipe_page.dart';
import 'package:fp_recipemanager/pages/recipe_page.dart';
import 'package:fp_recipemanager/pages/user_profile_page.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
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
              text: "View Recipes", icon: Icons.fastfood, onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => RecipePage(),),);
          }),
          MyDrawerTile(
              text: "View My Recipes", icon: Icons.fastfood, onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyRecipePage(),),);
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
