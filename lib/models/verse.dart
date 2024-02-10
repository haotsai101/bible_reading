class Verse {
  final String? id;
  final String bibleId;
  final String bookId;
  final String? chapterId; // Make sure to add chapterId in your Verse model
  final String number;
  final String content;
  bool highlighted;
  bool marked;

  Verse({
    this.id,
    required this.bibleId,
    required this.bookId,
    this.chapterId,
    required this.number,
    required this.content,
    this.highlighted = false,
    this.marked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bibleId': bibleId,
      'bookId': bookId,
      'chapterId': chapterId,
      'number': number,
      'content': content,
      'highlighted': highlighted ? 1 : 0,
      'marked': marked ? 1 : 0,
    };
  }

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'],
      bibleId: map['bibleId'],
      bookId: map['bookId'],
      chapterId: map['chapterId'],
      number: map['number'],
      content: map['content'],
      highlighted: map['highlighted'] == 1,
      marked: map['marked'] == 1,
    );
  }

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'],
      bibleId: json['bibleId'],
      bookId: json['bookId'],
      chapterId:
          json['chapterId'], // Assuming 'chapterId' is available in the JSON.
      number: json['number'],
      content: json['content'],
      highlighted: json['highlighted'] ??
          false, // Assuming 'highlighted' key might be optional in JSON.
      marked: json['marked'] ??
          false, // Assuming 'marked' key might be optional in JSON.
    );
  }
}
