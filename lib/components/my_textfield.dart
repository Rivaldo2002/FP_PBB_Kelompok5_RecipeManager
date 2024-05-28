import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  // Allows us to access user input
  final controller;

  // Hint on what should be typed in
  final String hintText;

  // Hide characters when we're typing the password
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Color(0xff343434)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: Colors.white),
            ),
            fillColor: Color(0xff191919),
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(
                color: Color(0xff616161),
                fontWeight: FontWeight.normal
            )
        ),
      ),
    );
  }
}
