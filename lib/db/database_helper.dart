import 'dart:convert';

import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/models/book.dart';
import 'package:bible_reading/models/chapter.dart';
import 'package:bible_reading/models/verse.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static List<Map<String, dynamic>> defaultBooks = [];

  static List<Map<String, dynamic>> getDefaultBooks() {
    if (defaultBooks.isEmpty) {
      String defaultBooksJson = dotenv.env['DEFAULT_BOOKS_JSON']!;
      defaultBooks =
          List<Map<String, dynamic>>.from(json.decode(defaultBooksJson));
    }
    return defaultBooks;
  }

  static String defaultBibleId = 'defaultBibleId';

  static Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    // final path = join(dbPath, 'bible.db');
    // await deleteDatabase(path);

    return openDatabase(
      join(dbPath, 'bible.db'),
      onCreate: (db, version) async {
        // Bibles Table
        await db.execute(
          'CREATE TABLE Bibles(id TEXT PRIMARY KEY, name TEXT, description TEXT, abbreviation TEXT, language TEXT)',
        );
        // Books Table
        await db.execute(
          'CREATE TABLE Books(id TEXT, bibleId TEXT, abbreviation TEXT, name TEXT, nameLong TEXT, FOREIGN KEY(bibleId) REFERENCES Bibles(id))',
        );
        // Chapters Table
        await db.execute(
          'CREATE TABLE Chapters(id TEXT, bibleId TEXT, bookId TEXT, number TEXT, reference TEXT, FOREIGN KEY(bibleId) REFERENCES Bibles(id), FOREIGN KEY(bookId) REFERENCES Books(id))',
        );
        // Verses Table
        await db.execute(
          'CREATE TABLE Verses(id TEXT PRIMARY KEY, bibleId TEXT, bookId TEXT, chapterId TEXT, number TEXT, content TEXT, highlighted INTEGER, marked INTEGER, FOREIGN KEY(bibleId) REFERENCES Bibles(id), FOREIGN KEY(bookId) REFERENCES Books(id), FOREIGN KEY(chapterId) REFERENCES Chapters(id))',
        );

        await db.transaction((txn) async {
          // Insert the default Bible
          await txn.insert('Bibles', {
            'id': defaultBibleId,
            'name': 'Default Bible',
            'description': 'This is the default Bible.',
            'abbreviation': 'DefBib',
            'language': 'English',
          });

          // Insert default books and chapters
          for (Map<String, dynamic> bookInfo in getDefaultBooks()) {
            String bookId = bookInfo['id'];
            await txn.insert('Books', {
              'id': bookId,
              'bibleId': defaultBibleId,
              'abbreviation': bookId,
              'name': bookInfo['name'],
              'nameLong': bookInfo['name'] + " Long Name",
            });

            int chapterCount = bookInfo['chapters'];
            for (int i = 1; i <= chapterCount; i++) {
              await txn.insert('Chapters', {
                'id': '$bookId.$i',
                'bibleId': defaultBibleId,
                'bookId': bookId,
                'number': i.toString(),
                'reference': '${bookInfo['name']} $i',
              });
            }
          }
        });
      },
      version: 1,
    );
  }

  // Insert methods for each table
  static Future<void> insertBible(Bible bible) async {
    final db = await getDatabase();
    await db.insert('Bibles', bible.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> insertBook(Book book) async {
    final db = await getDatabase();
    await db.insert('Books', book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> insertChapter(Chapter chapter) async {
    final db = await getDatabase();
    await db.insert('Chapters', chapter.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> insertVerse(Verse verse) async {
    final db = await getDatabase();
    await db.insert('Verses', verse.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get methods for each table
  static Future<List<Bible>> getBibles() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'Bibles',
      where: 'id != ?', // Add a WHERE clause to exclude the default Bible ID
      whereArgs: [
        defaultBibleId
      ], // Provide the default Bible ID as a parameter
    );
    return List.generate(maps.length, (i) => Bible.fromMap(maps[i]));
  }

  static Future<List<Book>> getBooks() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query('Books', where: 'bibleId = ?', whereArgs: [defaultBibleId]);
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }

  static Future<List<Chapter>> getChapters(String bookId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('Chapters',
        where: 'bookId = ? AND bibleId = ?',
        whereArgs: [bookId, defaultBibleId]);
    return List.generate(maps.length, (i) => Chapter.fromMap(maps[i]));
  }

  // Method to get verses based on multiple bibleIds, a bookId, and a chapterId, ordered by number and then by bibleId
  static Future<List<Verse>> getVersesByChapter(
      List<String> bibleIds, String bookId, String chapterId) async {
    final db = await getDatabase();

    // Generating placeholders for each bibleId
    final String placeholders = List.filled(bibleIds.length, '?').join(', ');

    final List<Map<String, dynamic>> maps = await db.query(
      'Verses',
      where: 'bibleId IN ($placeholders) AND bookId = ? AND chapterId = ?',
      whereArgs: [
        ...bibleIds,
        bookId,
        chapterId
      ], // Spreading bibleIds into whereArgs
      // Splitting the 'number' column into numeric and char parts for sorting
      orderBy: """
      CAST(substr(number, 1, CASE WHEN instr(number, ' ') = 0 THEN length(number) ELSE instr(number, ' ') - 1 END) AS INTEGER), 
      substr(number, CASE WHEN instr(number, ' ') = 0 THEN length(number)+1 ELSE instr(number, ' ') + 1 END)
    """,
    );

    return List.generate(maps.length, (i) => Verse.fromMap(maps[i]));
  }

  // Method to get a specific chapter by chapterId
  static Future<Chapter?> getChapter(String chapterId, String? bibleId) async {
    final db =
        await getDatabase(); // Assuming getDatabase() provides a singleton instance of the database
    final List<Map<String, dynamic>> maps = await db.query(
      'Chapters',
      where: 'id = ? AND bibleId = ?',
      whereArgs: [chapterId, bibleId ?? defaultBibleId],
      limit: 1, // Expecting only one match for a unique chapterId
    );

    if (maps.isNotEmpty) {
      // If there's a match, return a Chapter object
      return Chapter.fromMap(maps
          .first); // Assuming you have a fromMap factory constructor in your Chapter model
    } else {
      // If no match is found, return null
      return null;
    }
  }

  // Method to get a specific book by bookId
  static Future<Book?> getBook(String bookId, String? bibleId) async {
    final db =
        await getDatabase(); // Assuming getDatabase() provides a singleton instance of the database
    final List<Map<String, dynamic>> maps = await db.query(
      'Books',
      where: 'id = ? AND bibleId = ?',
      whereArgs: [bookId, bibleId ?? defaultBibleId],
      limit: 1, // Expecting only one match for a unique chapterId
    );

    if (maps.isNotEmpty) {
      // If there's a match, return a Chapter object
      return Book.fromMap(maps
          .first); // Assuming you have a fromMap factory constructor in your Chapter model
    } else {
      // If no match is found, return null
      return null;
    }
  }

  // Method to get a specific bible by bibleId
  static Future<Bible?> getBible(String bibleId) async {
    final db =
        await getDatabase(); // Assuming getDatabase() provides a singleton instance of the database
    final List<Map<String, dynamic>> maps = await db.query(
      'Bibles',
      where: 'id = ?',
      whereArgs: [bibleId],
      limit: 1, // Expecting only one match for a unique chapterId
    );

    if (maps.isNotEmpty) {
      // If there's a match, return a Chapter object
      return Bible.fromMap(maps
          .first); // Assuming you have a fromMap factory constructor in your Chapter model
    } else {
      // If no match is found, return null
      return null;
    }
  }

  static Future<void> batchCreateBooks(List<Book> books) async {
    final db = await DatabaseHelper.getDatabase();

    await db.transaction((txn) async {
      for (var book in books) {
        await txn.insert('Books', book.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<void> batchCreateChapters(List<Chapter> chapters) async {
    final db = await DatabaseHelper.getDatabase();

    await db.transaction((txn) async {
      for (var chapter in chapters) {
        await txn.insert('Chapters', chapter.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<void> batchCreateVerses(List<Verse> verses) async {
    final db = await DatabaseHelper.getDatabase();

    await db.transaction((txn) async {
      for (var verse in verses) {
        await txn.insert('Verses', verse.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<void> batchCreateBible(Bible bible, List<Book> books,
      List<Chapter> chapters, List<Verse> verses) async {
    final db = await DatabaseHelper.getDatabase();

    await db.transaction((txn) async {
      await txn.insert('Bibles', bible.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      for (var book in books) {
        await txn.insert('Books', book.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (var chapter in chapters) {
        await txn.insert('Chapters', chapter.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (var verse in verses) {
        await txn.insert('Verses', verse.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<int> countBibles() async {
    final db = await getDatabase();
    final data = await db.rawQuery('SELECT COUNT(*) FROM Bibles');
    return Sqflite.firstIntValue(data) ?? 0; // Returns 0 if null
  }

  static Future<int> countBooks() async {
    final db = await getDatabase();
    final data = await db.rawQuery('SELECT COUNT(*) FROM Books');
    return Sqflite.firstIntValue(data) ?? 0; // Returns 0 if null
  }

  static Future<int> countChapters() async {
    final db = await getDatabase();
    final data = await db.rawQuery('SELECT COUNT(*) FROM Chapters');
    return Sqflite.firstIntValue(data) ?? 0; // Returns 0 if null
  }

  static Future<int> countVerses() async {
    final db = await getDatabase();
    final data = await db.rawQuery('SELECT COUNT(*) FROM Verses');
    return Sqflite.firstIntValue(data) ?? 0; // Returns 0 if null
  }
}
