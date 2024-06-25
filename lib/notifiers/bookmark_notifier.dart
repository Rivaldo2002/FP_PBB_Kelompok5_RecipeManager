import 'package:flutter/material.dart';
import 'package:fp_recipemanager/services/bookmark_service.dart';

class BookmarkNotifier extends ChangeNotifier {
  final BookmarkService bookmarkService;
  final String userId;
  Map<String, bool> _bookmarks = {};

  BookmarkNotifier(this.bookmarkService, this.userId);

  Future<void> loadBookmarks() async {
    final bookmarks = await bookmarkService.getBookmarks(userId).first;
    _bookmarks = {for (var bookmark in bookmarks) bookmark.recipeId: true};
    notifyListeners();
  }

  bool isBookmarked(String recipeId) {
    return _bookmarks[recipeId] ?? false;
  }

  Future<void> toggleBookmark(String recipeId) async {
    if (_bookmarks[recipeId] == true) {
      await bookmarkService.removeBookmark(userId, recipeId);
      _bookmarks.remove(recipeId);
    } else {
      await bookmarkService.addBookmark(userId, recipeId);
      _bookmarks[recipeId] = true;
    }
    notifyListeners();
  }
}
