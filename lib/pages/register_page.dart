import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fp_recipemanager/components/my_button.dart';
import 'package:fp_recipemanager/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text Editing Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Try creating the user
    FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
    try {
      // Check whether password and confirm password fields are the same
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        // Show error message, password don't match
        showErrorDialog('passwords-dont-match');
      }
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
      case 'passwords-dont-match':
        errorTitle = "Passwords Don't Match!";
        errorMessage = 'Please re-enter your password.';
        break;
      case 'weak-password':
        errorTitle = "Password Too Weak!";
        errorMessage = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        errorTitle = "Email Already In Use!";
        errorMessage = 'The account already exists for that email.';
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
                  "Start eating healthier!",
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

                // Confirm Password Textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),
                SizedBox(height: 10),

                // Sign Up Button
                MyButton(
                  onTap: signUserUp,
                  text: "Sign Up",
                ),
                SizedBox(height: 25),

                // Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Sign In Now',
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
