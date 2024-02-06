import 'package:bible_reading/models/book.dart';
import 'package:bible_reading/models/chapter.dart';
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

      return bibleGroups;
    } else {
      throw Exception('Failed to load Bibles');
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

  // Helper function to group Bibles by language
  Map<String, List<Bible>> groupBiblesByLanguage(List<Bible> bibles) {
    return bibles.fold(<String, List<Bible>>{},
        (Map<String, List<Bible>> map, Bible bible) {
      map[bible.language] = map[bible.language] ?? [];
      map[bible.language]!.add(bible);
      return map;
    });
  }
}
