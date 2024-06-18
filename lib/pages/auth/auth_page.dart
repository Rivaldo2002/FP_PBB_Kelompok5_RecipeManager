import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipemanager/pages/auth/login_or_register_page.dart';
import 'package:fp_recipemanager/pages/recipe/recipe_page.dart';

// Check whether the user is logged in or not
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If user is logged in
          if(snapshot.hasData) {
            return RecipePage();
          }

          // If user is not logged in
          else {
            return LoginOrRegisterPage();
          }

        },
      ),
    );
  }
}
