import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fp_recipemanager/pages/auth_page.dart';
import 'package:fp_recipemanager/pages/home_page.dart';
import 'package:fp_recipemanager/pages/user_profile_page.dart';
import 'package:fp_recipemanager/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/restaurant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    // Theme provider
    ChangeNotifierProvider(create: (context) => ThemeProvider()),

    // Restaurant provider
    ChangeNotifierProvider(create: (context) => Restaurant()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: AuthPage(),
    );
  }
}
