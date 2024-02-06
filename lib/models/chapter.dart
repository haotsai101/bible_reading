class Chapter {
  final String id;
  final String bibleId;
  final String bookId;
  final String number;
  final String reference;

  Chapter({
    required this.id,
    required this.bibleId,
    required this.bookId,
    required this.number,
    required this.reference,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      bibleId: json['bibleId'],
      bookId: json['bookId'],
      number: json['number'],
      reference: json['reference'],
    );
  }
}
