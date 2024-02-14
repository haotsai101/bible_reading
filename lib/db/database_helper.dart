import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/models/book.dart';
import 'package:bible_reading/models/chapter.dart';
import 'package:bible_reading/models/verse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    // final path = join(dbPath, 'bible.db');
    // await deleteDatabase(path);

    return openDatabase(
      join(dbPath, 'bible.db'),
      onCreate: (db, version) async {
        // Bibles Table
        await db.execute(
          'CREATE TABLE Bibles(id TEXT PRIMARY KEY, name TEXT, description TEXT, abbreviation TEXT, language TEXT, isSelected INTEGER)',
        );
        // Books Table
        await db.execute(
          'CREATE TABLE Books(id TEXT PRIMARY KEY, bibleId TEXT, abbreviation TEXT, name TEXT, nameLong TEXT, FOREIGN KEY(bibleId) REFERENCES Bibles(id))',
        );
        // Chapters Table
        await db.execute(
          'CREATE TABLE Chapters(id TEXT PRIMARY KEY, bibleId TEXT, bookId TEXT, number TEXT, reference TEXT, FOREIGN KEY(bibleId) REFERENCES Bibles(id), FOREIGN KEY(bookId) REFERENCES Books(id))',
        );
        // Verses Table
        await db.execute(
          'CREATE TABLE Verses(id TEXT PRIMARY KEY, bibleId TEXT, bookId TEXT, chapterId TEXT, number TEXT, content TEXT, highlighted INTEGER, marked INTEGER, FOREIGN KEY(bibleId) REFERENCES Bibles(id), FOREIGN KEY(bookId) REFERENCES Books(id), FOREIGN KEY(chapterId) REFERENCES Chapters(id))',
        );
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
    final List<Map<String, dynamic>> maps = await db.query('Bibles');
    return List.generate(maps.length, (i) => Bible.fromMap(maps[i]));
  }

  static Future<List<Book>> getBooks(String bibleId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('Books', where: 'bibleId = ?', whereArgs: [bibleId]);
    return List.generate(maps.length, (i) => Book.fromMap(maps[i]));
  }

  static Future<List<Chapter>> getChapters(String bookId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('Chapters', where: 'bookId = ?', whereArgs: [bookId]);
    return List.generate(maps.length, (i) => Chapter.fromMap(maps[i]));
  }

  static Future<List<Verse>> getVerses(String chapterId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query('Verses', where: 'chapterId = ?', whereArgs: [chapterId]);
    return List.generate(maps.length, (i) => Verse.fromMap(maps[i]));
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
      orderBy:
          'CAST(number AS INTEGER), bibleId', // Order by number as integer and then by bibleId
    );
    return List.generate(maps.length, (i) => Verse.fromMap(maps[i]));
  }

  // Method to get a specific chapter by chapterId
  static Future<Chapter?> getChapter(String chapterId) async {
    final db =
        await getDatabase(); // Assuming getDatabase() provides a singleton instance of the database
    final List<Map<String, dynamic>> maps = await db.query(
      'Chapters',
      where: 'id = ?',
      whereArgs: [chapterId],
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
  static Future<Book?> getBook(String bookId) async {
    final db =
        await getDatabase(); // Assuming getDatabase() provides a singleton instance of the database
    final List<Map<String, dynamic>> maps = await db.query(
      'Books',
      where: 'id = ?',
      whereArgs: [bookId],
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
}
