class BibleVerse {
  final int? id;
  final String book;
  final int chapter;
  final int verse;
  final String text;
  final String version;
  final bool highlighted;
  final bool marked;

  BibleVerse({
    this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.version,
    this.highlighted = false,
    this.marked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'version': version,
      'highlighted': highlighted
          ? 1
          : 0, // SQLite does not have a BOOLEAN type, use INTEGER instead
      'marked': marked ? 1 : 0,
    };
  }

  BibleVerse.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        book = map['book'],
        chapter = map['chapter'],
        verse = map['verse'],
        text = map['text'],
        version = map['version'],
        highlighted = map['highlighted'] == 1,
        marked = map['marked'] == 1;
}
