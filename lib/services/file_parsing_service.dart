import 'dart:io';
import 'package:bible_reading/db/database_helper.dart';
import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/models/book.dart';
import 'package:bible_reading/models/chapter.dart';
import 'package:bible_reading/models/verse.dart';
import 'package:path/path.dart';

Future<Bible> parseAndSaveVerses(String filePath) async {
  final File file = File(filePath);
  final String filename = basename(file.path);
  final String bibleId = filename;
  final String bibleName = filename;
  final String bibleAbbreviation =
      filename.length > 5 ? filename.substring(0, 5) : filename;

  // Create a new Bible entry

  Bible newBible = Bible(
    id: bibleId,
    name: bibleName,
    description: bibleName,
    abbreviation: bibleAbbreviation,
    language: 'en',
  );

  List<String> lines = await file.readAsLines();
  String curBookAbbr = '';
  int c = -1;
  String cc = '';
  List<Book> books = [];
  List<Chapter> chapters = [];
  List<Verse> verses = [];

  for (String line in lines) {
    if (line.isNotEmpty) {
      final RegExp pattern = RegExp(r'^(\D+)(\d+):(\d+)\s+(.*)');
      final match = pattern.firstMatch(line);

      if (match == null) {
        continue;
      }

      final String bookAbbr = match.group(1)!.trim(); // Book abbreviation
      final String chapterNumber = match.group(2)!; // Chapter number
      final String verseNum = match.group(3)!; // Verse number
      final String content = match.group(4)!; // Verse content

      try {
        if (curBookAbbr == '' || curBookAbbr != bookAbbr) {
          curBookAbbr = bookAbbr;
          c += 1;
          Map<String, dynamic> bookInfo = DatabaseHelper.defaultBooks[c];
          String bookId = bookInfo['id'];
          Book book = Book(
            id: bookId,
            bibleId: newBible.id,
            abbreviation: bookAbbr,
            name: bookInfo['name'],
            nameLong: bookInfo['name'] + " Long Name",
          );
          books.add(book);
        }
      } catch (e) {
        rethrow;
      }

      try {
        if (cc == '' || cc != chapterNumber) {
          cc = chapterNumber;
          Map<String, dynamic> bookInfo = DatabaseHelper.defaultBooks[c];
          String bookId = bookInfo['id'];
          String chapterId = '$bookId.$chapterNumber';
          Chapter chapter = Chapter(
              id: chapterId,
              bibleId: bibleId,
              bookId: bookId,
              number: chapterNumber,
              reference: '${bookInfo['name']} $chapterNumber');
          chapters.add(chapter);
        }
      } catch (e) {
        rethrow;
      }

      try {
        Map<String, dynamic> bookInfo = DatabaseHelper.defaultBooks[c];

        Verse verse = Verse(
          id: '${bookInfo['id']}-$chapterNumber-$verseNum',
          bibleId: bibleId,
          bookId: bookInfo['id'],
          chapterId: '${bookInfo['id']}.$chapterNumber',
          number: verseNum,
          content: content,
        );
        verses.add(verse);
      } catch (e) {
        rethrow;
      }
    }
  }

  try {
    DatabaseHelper.batchCreateBible(newBible, books, chapters, verses);
  } catch (e) {
    rethrow;
  }

  return newBible;
}
