import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/models/book.dart';
import 'package:bible_reading/models/chapter.dart';
import 'package:bible_reading/models/verse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static List<Map<String, dynamic>> defaultBooks = [
    {'id': 'GEN', 'name': 'Genesis', 'chapters': 50},
    {'id': 'EXO', 'name': 'Exodus', 'chapters': 40},
    {'id': 'LEV', 'name': 'Leviticus', 'chapters': 27},
    {'id': 'NUM', 'name': 'Numbers', 'chapters': 36},
    {'id': 'DEU', 'name': 'Deuteronomy', 'chapters': 34},
    {'id': 'JOS', 'name': 'Joshua', 'chapters': 24},
    {'id': 'JDG', 'name': 'Judges', 'chapters': 21},
    {'id': 'RUT', 'name': 'Ruth', 'chapters': 4},
    {'id': '1SA', 'name': '1 Samuel', 'chapters': 31},
    {'id': '2SA', 'name': '2 Samuel', 'chapters': 24},
    {'id': '1KI', 'name': '1 Kings', 'chapters': 22},
    {'id': '2KI', 'name': '2 Kings', 'chapters': 25},
    {'id': '1CH', 'name': '1 Chronicles', 'chapters': 29},
    {'id': '2CH', 'name': '2 Chronicles', 'chapters': 36},
    {'id': 'EZR', 'name': 'Ezra', 'chapters': 10},
    {'id': 'NEH', 'name': 'Nehemiah', 'chapters': 13},
    {'id': 'EST', 'name': 'Esther', 'chapters': 10},
    {'id': 'JOB', 'name': 'Job', 'chapters': 42},
    {'id': 'PSA', 'name': 'Psalms', 'chapters': 150},
    {'id': 'PRO', 'name': 'Proverbs', 'chapters': 31},
    {'id': 'ECC', 'name': 'Ecclesiastes', 'chapters': 12},
    {'id': 'SNG', 'name': 'Song of Solomon', 'chapters': 8},
    {'id': 'ISA', 'name': 'Isaiah', 'chapters': 66},
    {'id': 'JER', 'name': 'Jeremiah', 'chapters': 52},
    {'id': 'LAM', 'name': 'Lamentations', 'chapters': 5},
    {'id': 'EZK', 'name': 'Ezekiel', 'chapters': 48},
    {'id': 'DAN', 'name': 'Daniel', 'chapters': 12},
    {'id': 'HOS', 'name': 'Hosea', 'chapters': 14},
    {'id': 'JOL', 'name': 'Joel', 'chapters': 3},
    {'id': 'AMO', 'name': 'Amos', 'chapters': 9},
    {'id': 'OBA', 'name': 'Obadiah', 'chapters': 1},
    {'id': 'JON', 'name': 'Jonah', 'chapters': 4},
    {'id': 'MIC', 'name': 'Micah', 'chapters': 7},
    {'id': 'NAM', 'name': 'Nahum', 'chapters': 3},
    {'id': 'HAB', 'name': 'Habakkuk', 'chapters': 3},
    {'id': 'ZEP', 'name': 'Zephaniah', 'chapters': 3},
    {'id': 'HAG', 'name': 'Haggai', 'chapters': 2},
    {'id': 'ZEC', 'name': 'Zechariah', 'chapters': 14},
    {'id': 'MAL', 'name': 'Malachi', 'chapters': 4},
    {'id': 'MAT', 'name': 'Matthew', 'chapters': 28},
    {'id': 'MRK', 'name': 'Mark', 'chapters': 16},
    {'id': 'LUK', 'name': 'Luke', 'chapters': 24},
    {'id': 'JHN', 'name': 'John', 'chapters': 21},
    {'id': 'ACT', 'name': 'Acts', 'chapters': 28},
    {'id': 'ROM', 'name': 'Romans', 'chapters': 16},
    {'id': '1CO', 'name': '1 Corinthians', 'chapters': 16},
    {'id': '2CO', 'name': '2 Corinthians', 'chapters': 13},
    {'id': 'GAL', 'name': 'Galatians', 'chapters': 6},
    {'id': 'EPH', 'name': 'Ephesians', 'chapters': 6},
    {'id': 'PHP', 'name': 'Philippians', 'chapters': 4},
    {'id': 'COL', 'name': 'Colossians', 'chapters': 4},
    {'id': '1TH', 'name': '1 Thessalonians', 'chapters': 5},
    {'id': '2TH', 'name': '2 Thessalonians', 'chapters': 3},
    {'id': '1TI', 'name': '1 Timothy', 'chapters': 6},
    {'id': '2TI', 'name': '2 Timothy', 'chapters': 4},
    {'id': 'TIT', 'name': 'Titus', 'chapters': 3},
    {'id': 'PHM', 'name': 'Philemon', 'chapters': 1},
    {'id': 'HEB', 'name': 'Hebrews', 'chapters': 13},
    {'id': 'JAS', 'name': 'James', 'chapters': 5},
    {'id': '1PE', 'name': '1 Peter', 'chapters': 5},
    {'id': '2PE', 'name': '2 Peter', 'chapters': 3},
    {'id': '1JN', 'name': '1 John', 'chapters': 5},
    {'id': '2JN', 'name': '2 John', 'chapters': 1},
    {'id': '3JN', 'name': '3 John', 'chapters': 1},
    {'id': 'JUD', 'name': 'Jude', 'chapters': 1},
    {'id': 'REV', 'name': 'Revelation', 'chapters': 22},
  ];

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
          for (Map<String, dynamic> bookInfo in defaultBooks) {
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

  // Function to mark or unmark a verse
  static Future<void> markUnmarkVerse(String verseId, bool mark) async {
    final db = await getDatabase();
    await db.update(
      'Verses',
      {'marked': mark ? 1 : 0},
      where: 'id = ?',
      whereArgs: [verseId],
    );
  }

  // Function to highlight or unhighlight a verse
  static Future<void> highlightUnhighlightVerse(
      String verseId, bool highlight) async {
    final db = await getDatabase();
    await db.update(
      'Verses',
      {'highlighted': highlight ? 1 : 0},
      where: 'id = ?',
      whereArgs: [verseId],
    );
  }

  static Future<void> deleteBible(String bibleId) async {
    final db = await getDatabase();
    await db.transaction((txn) async {
      // First, delete all verses related to this Bible
      await txn.delete(
        'Verses',
        where: 'bibleId = ?',
        whereArgs: [bibleId],
      );

      // Next, delete all chapters related to this Bible
      await txn.delete(
        'Chapters',
        where: 'bibleId = ?',
        whereArgs: [bibleId],
      );

      // Then, delete all books related to this Bible
      await txn.delete(
        'Books',
        where: 'bibleId = ?',
        whereArgs: [bibleId],
      );

      // Finally, delete the Bible itself
      await txn.delete(
        'Bibles',
        where: 'id = ?',
        whereArgs: [bibleId],
      );
    });
  }
}
