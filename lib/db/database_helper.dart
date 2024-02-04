import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/bible_verse.dart';

class DatabaseHelper {
  static Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    // final path = join(dbPath, 'bible.db');
    // await deleteDatabase(path);

    return openDatabase(
      join(dbPath, 'bible.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE verses(id INTEGER PRIMARY KEY AUTOINCREMENT, book TEXT, chapter INTEGER, verse INTEGER, text TEXT, version TEXT, highlighted BOOLEAN, marked BOOLEAN)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertVerse(BibleVerse verse) async {
    final db = await DatabaseHelper.getDatabase();
    await db.insert(
      'verses',
      verse.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<BibleVerse>> getVerses() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('verses');

    return List.generate(maps.length, (i) {
      return BibleVerse(
        id: maps[i]['id'],
        book: maps[i]['book'],
        chapter: maps[i]['chapter'],
        verse: maps[i]['verse'],
        text: maps[i]['text'],
        version: maps[i]['version'],
        highlighted: maps[i]['highlighted'] == 1, // Convert INTEGER to bool
        marked: maps[i]['marked'] == 1, // Convert INTEGER to bool
      );
    });
  }

  static Future<List<BibleVerse>> getHighlightedVerses() async {
    final db = await DatabaseHelper.getDatabase();
    // Query the database for all verses where 'highlighted' is 1
    final List<Map<String, dynamic>> maps = await db.query(
      'verses',
      where: 'highlighted = ?',
      whereArgs: [1], // SQLite uses 1 for true
    );

    return List.generate(maps.length, (i) {
      return BibleVerse.fromMap(
          maps[i]); // Assuming you have a fromMap constructor for convenience
    });
  }

  static Future<List<BibleVerse>> getMarkedVerses() async {
    final db = await DatabaseHelper.getDatabase();
    // Query the database for all verses where 'marked' is 1
    final List<Map<String, dynamic>> maps = await db.query(
      'verses',
      where: 'marked = ?',
      whereArgs: [1], // SQLite uses 1 for true
    );

    return List.generate(maps.length, (i) {
      return BibleVerse.fromMap(
          maps[i]); // Assuming you have a fromMap constructor for convenience
    });
  }
}
