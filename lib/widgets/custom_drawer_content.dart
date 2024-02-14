import 'package:bible_reading/models/book.dart';
import 'package:bible_reading/models/chapter.dart';
import 'package:bible_reading/models/verse.dart';
import 'package:bible_reading/services/reading_manager.dart';
import 'package:flutter/material.dart';

class CustomDrawerContent extends StatefulWidget {
  final updateData;

  const CustomDrawerContent({Key? key, required this.updateData})
      : super(key: key);

  @override
  _CustomDrawerContentState createState() => _CustomDrawerContentState();
}

class _CustomDrawerContentState extends State<CustomDrawerContent> {
  List<Book> books = [];
  Map<String, List<Chapter>> booksMap =
      {}; // Map to hold Bible ID to Bible object

  @override
  initState() {
    super.initState();
    ReadingManager().getBooks().then((b) async {
      Map<String, List<Chapter>> tempBooksMap = {};
      for (var book in b) {
        var chapters = await ReadingManager().getChapters(book.id);
        tempBooksMap[book.id] = chapters;
      }
      setState(() {
        booksMap = tempBooksMap;
        books = b;
      });
    });
  }

  void onChapterClicked(Book book, Chapter chapter) async {
    await ReadingManager().updateBookId(chapter.bookId);
    await ReadingManager().updateChapterId(chapter.id);
    widget.updateData(); // Call the callback passed from MyHomePage
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          Book book = books[index];
          List<Chapter> chapters = booksMap[book.id] ??
              []; // Get chapters for the book, defaulting to an empty list if not found

          return ExpansionTile(
            title: Text(book.name),
            children: <Widget>[
              SizedBox(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                  ),
                  itemCount: chapters.length,
                  itemBuilder: (context, gridIndex) {
                    Chapter chapter = chapters[gridIndex];
                    return GridTile(
                      child: TextButton(
                        onPressed: () => onChapterClicked(book,
                            chapter), // Define this function to handle chapter clicks
                        child: Text(chapter.number),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
