import 'package:bible_reading/db/database_helper.dart';
import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/models/book.dart';
import 'package:bible_reading/models/chapter.dart';
import 'package:bible_reading/models/verse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingManager {
  static final ReadingManager _instance = ReadingManager._();

  Set<String> bibleIds = {};
  String bookId = 'GEN';
  String chapterId = 'GEN.1';

  // Private constructor
  ReadingManager._();

  // Factory constructor to return the same instance
  factory ReadingManager() {
    return _instance;
  }

  static const _bibleIdsKey = 'bibleIds';
  static const _bookIdKey = 'bookId';
  static const _chapterIdKey = 'chapterId';

  // Method to initialize from SharedPreferences, this can be called from your main.dart or initState of your first screen
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    bibleIds = Set<String>.from(prefs.getStringList(_bibleIdsKey) ?? []);
    List<Bible> bibles = await DatabaseHelper.getBibles();
    Set<String> validBibleIds = bibles.map((bible) => bible.id).toSet();
    bibleIds.removeWhere((id) => !validBibleIds.contains(id));
    await prefs.setStringList(_bibleIdsKey, bibleIds.toList());

    bookId = prefs.getString(_bookIdKey) ?? 'GEN';
    chapterId = prefs.getString(_chapterIdKey) ?? 'GEN.1';
    // Here you can notify listeners or update UI as needed
  }

  Future<void> updateBibleIds(Set<String> newBibleIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bibleIdsKey, newBibleIds.toList());
    bibleIds = newBibleIds;
  }

  Future<void> addBibleId(String newBibleId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!bibleIds.contains(newBibleId)) {
      bibleIds.add(newBibleId);
      // Convert Set to List before saving
      await prefs.setStringList(_bibleIdsKey, bibleIds.toList());
    }
  }

  Future<void> removeBibleId(String bibleIdToRemove) async {
    final prefs = await SharedPreferences.getInstance();
    if (bibleIds.contains(bibleIdToRemove)) {
      bibleIds.remove(bibleIdToRemove);
      // Convert Set to List before saving
      await prefs.setStringList(_bibleIdsKey, bibleIds.toList());
    }
  }

  Future<void> updateBookId(String newBookId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bookIdKey, newBookId);
    bookId = newBookId;
  }

  Future<void> updateChapterId(String newChapterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chapterIdKey, newChapterId);
    chapterId = newChapterId;
  }

  // Getters
  Set<String> get currentBibleIds => bibleIds;
  String get currentBookId => bookId;
  String get currentChapterId => chapterId;

  // Method to get bibles
  Future<List<Bible>> getBibles() async {
    return await DatabaseHelper.getBibles();
  }

  // Method to get books for the current Bible
  Future<List<Book>> getBooks() async {
    return await DatabaseHelper.getBooks();
  }

  // Method to get chapters for the current book
  Future<List<Chapter>> getChapters(String bookId) async {
    return await DatabaseHelper.getChapters(bookId);
  }

  // Method to get the current chapter
  Future<Chapter?> getChapter() async {
    return await DatabaseHelper.getChapter(
        chapterId, bibleIds.isNotEmpty ? bibleIds.first : null);
  }

  // Method to get the current chapter
  Future<Book?> getBook() async {
    return await DatabaseHelper.getBook(
        bookId, bibleIds.isNotEmpty ? bibleIds.first : null);
  }

  // Method to get verses by chapter considering multiple Bible IDs
  Future<List<Verse>> getVersesByChapter() async {
    return await DatabaseHelper.getVersesByChapter(
        bibleIds.toList(), bookId, chapterId);
  }
}
