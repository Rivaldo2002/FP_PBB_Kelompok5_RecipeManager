import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fp_recipemanager/pages/auth/auth_page.dart';
import 'package:fp_recipemanager/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_recipemanager/notifiers/bookmark_notifier.dart';
import 'package:fp_recipemanager/services/bookmark_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure FirebaseAuth is ready before proceeding
  await FirebaseAuth.instance.userChanges().first;

  runApp(
    MultiProvider(
      providers: [
        // Theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // Bookmark provider
        ChangeNotifierProvider<BookmarkNotifier>(
          create: (context) {
            final user = FirebaseAuth.instance.currentUser;
            final bookmarkService = BookmarkService();
            final bookmarkNotifier = BookmarkNotifier(bookmarkService, user!.uid);
            bookmarkNotifier.loadBookmarks();
            return bookmarkNotifier;
          },
        ),
      ],
      child: MyApp(),
    ),
  );
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
