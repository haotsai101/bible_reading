import 'package:bible_reading/db/database_helper.dart';
import 'package:bible_reading/models/book.dart';
import 'package:bible_reading/models/chapter.dart';
import 'package:bible_reading/models/verse.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/bible.dart'; // Ensure this model has a 'language' property

class BibleService {
  Future<List<BibleGroup>> fetchBibles() async {
    final apiKey = dotenv.env['API_KEY']; // Access the API key
    final response = await http.get(
      Uri.parse('https://api.scripture.api.bible/v1/bibles'),
      headers: {'api-key': apiKey!, 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> biblesJson = data['data'];
      List<Bible> bibles =
          biblesJson.map((json) => Bible.fromJson(json)).toList();

      // Group Bibles by language
      var groupedByLanguage = groupBiblesByLanguage(bibles);

      // Map each group to a BibleGroup instance
      List<BibleGroup> bibleGroups = groupedByLanguage.entries.map((entry) {
        return BibleGroup(language: entry.key, bibles: entry.value);
      }).toList();
      bibleGroups.sort((a, b) => a.language.compareTo(b.language));

      return bibleGroups;
    } else {
      throw Exception('Failed to load Bibles ${response.body}');
    }
  }

  Future<List<Book>> fetchBooks(String bibleId) async {
    final apiKey = dotenv.env['API_KEY']; // Access the API key
    final response = await http.get(
      Uri.parse('https://api.scripture.api.bible/v1/bibles/$bibleId/books'),
      headers: {'api-key': apiKey!, 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> booksJson = data['data'];

      // Convert the JSON books to a list of Book model objects
      List<Book> books = booksJson.map((json) => Book.fromJson(json)).toList();
      return books;
    } else {
      throw Exception('Failed to load books for Bible ID: $bibleId');
    }
  }

  Future<List<Chapter>> fetchChapters(String bibleId, String bookId) async {
    final apiKey = dotenv.env['API_KEY']; // Access the API key
    final response = await http.get(
      Uri.parse(
          'https://api.scripture.api.bible/v1/bibles/$bibleId/books/$bookId/chapters'),
      headers: {'api-key': apiKey!, 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> chaptersJson = data['data'];

      // Convert the JSON chapters to a list of Chapter model objects
      List<Chapter> chapters =
          chaptersJson.map((json) => Chapter.fromJson(json)).toList();
      return chapters;
    } else {
      throw Exception(
          'Failed to load chapters for Bible ID: $bibleId and Book ID: $bookId');
    }
  }

  Future<List<Verse>> fetchVerses(String bibleId, String chapterId) async {
    final apiKey = dotenv.env['API_KEY']; // Access the API key
    final response = await http.get(
      Uri.parse(
          'https://api.scripture.api.bible/v1/bibles/$bibleId/chapters/$chapterId?content-type=text'),
      headers: {'api-key': apiKey!, 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];

      // Convert the JSON data to a Verse model object
      Verse verse = Verse.fromJson(data);
      List<Verse> verses = parseVerses(verse, chapterId);
      return verses;
    } else {
      throw Exception(
          'Failed to load verses for Bible ID: $bibleId and Chapter ID: $chapterId');
    }
  }

  // Helper function to group Bibles by language
  Map<String, List<Bible>> groupBiblesByLanguage(List<Bible> bibles) {
    return bibles.fold(<String, List<Bible>>{},
        (Map<String, List<Bible>> map, Bible bible) {
      map[bible.language] = map[bible.language] ?? [];
      map[bible.language]!.add(bible);
      return map;
    });
  }

  List<Verse> parseVerses(Verse parent, String chapterId) {
    List<Verse> verses = [];
    RegExp regExp = RegExp(r'\[\d+\]'); // Matches [Verse Number]

    // Split the content by the regex, but also keep the delimiters
    var parts = parent.content
        .splitMapJoin(regExp,
            onMatch: (m) => '${m.group(0)}',
            onNonMatch: (n) => '\u{FFFF}$n\u{FFFF}')
        .split('\u{FFFF}');

    String currentVerseNumber = '';
    for (var part in parts) {
      if (regExp.hasMatch(part)) {
        // Extract the verse number, removing brackets
        currentVerseNumber = part.replaceAll(RegExp(r'[\[\]]'), '');
      } else {
        // Trim the verse text to remove any leading/trailing whitespace
        String verseText = part.trim();
        if (verseText.isNotEmpty) {
          verses.add(Verse(
              number: currentVerseNumber,
              content: verseText,
              chapterId: chapterId,
              bibleId: parent.bibleId,
              bookId: parent.bookId));
        }
      }
    }

    return verses;
  }

  Future<void> downloadBible(Bible bible) async {
    String bibleId = bible.id;
    try {
      // Fetch and insert books
      final books = await fetchBooks(bibleId);

      // Fetch chapters for each book concurrently
      final chaptersFutures =
          books.map((book) => fetchChapters(bibleId, book.id));
      final chaptersList = await Future.wait(chaptersFutures);

      List<List<Verse>> versesList = [];

      for (var chapters in chaptersList) {
        // Fetch and insert verses for each chapter concurrently
        final versesFuture =
            chapters.map((chapter) => fetchVerses(bibleId, chapter.id));
        versesList.addAll(await Future.wait(versesFuture));
      }

      List<Chapter> chapters = chaptersList.expand((list) => list).toList();
      List<Verse> verses = versesList.expand((list) => list).toList();

      await DatabaseHelper.batchCreateBible(bible, books, chapters, verses);
    } catch (e) {
      throw ("Error downloading Bible: $e");
    }
  }
}
