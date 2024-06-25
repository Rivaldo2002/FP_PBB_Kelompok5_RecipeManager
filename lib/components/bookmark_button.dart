import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fp_recipemanager/notifiers/bookmark_notifier.dart';

class BookmarkButton extends StatelessWidget {
  final String recipeId;

  BookmarkButton({
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    final bookmarkNotifier = Provider.of<BookmarkNotifier>(context);
    final isBookmarked = bookmarkNotifier.isBookmarked(recipeId);

    return CircleAvatar(
      backgroundColor: Colors.white,
      child: IconButton(
        icon: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: isBookmarked ? Colors.black : Colors.grey,
        ),
        onPressed: () => bookmarkNotifier.toggleBookmark(recipeId),
      ),
    );
  }
}
