import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fp_recipemanager/components/my_button.dart';
import 'package:fp_recipemanager/components/my_textfield.dart';
import 'package:fp_recipemanager/components/square_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text Editing Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Close the loading dialog only if sign-in is successful
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Ensure loading dialog is closed on error
      Navigator.pop(context);
      showErrorDialog(e.code);
    }
  }

  void showErrorDialog(String errorCode) {
    String errorTitle;
    String errorMessage;

    switch (errorCode) {
      case 'user-not-found':
        errorTitle = 'User Not Found';
        errorMessage = 'No user found with the provided email address.';
        break;
      case 'wrong-password':
        errorTitle = 'Incorrect Password';
        errorMessage = 'The password you entered is incorrect.';
        break;
      case 'invalid-credential':
        errorTitle = 'Invalid Credential';
        errorMessage = 'Email or password is incorrect. Please try again.';
        break;
      case 'too-many-requests':
        errorTitle = 'Too Many Requests';
        errorMessage =
        'Too many requests have been made. Please try again later.';
        break;
      default:
        errorTitle = 'Error';
        errorMessage = 'An undefined error occurred. Please try again later.';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            errorTitle,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
          content: Text('Error Code: $errorCode\n\n$errorMessage'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                // Logo
                SvgPicture.asset(
                  'images/fitchen_logo_00.svg',
                  semanticsLabel: 'SVG Image',
                  height: 250,
                ),
                SizedBox(height: 50),

                // Welcome Back
                Text(
                  "Welcome Back, You've been missed!",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 25),

                // Username Textfield
                MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                SizedBox(height: 10),

                // Password Textfield
                MyTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                SizedBox(height: 10),

                // Sign In Button
                MyButton(
                  onTap: signUserIn,
                  text: "Sign In",
                ),
                SizedBox(height: 25),

                // Register Now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
