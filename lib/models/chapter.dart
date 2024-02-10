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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bibleId': bibleId,
      'bookId': bookId,
      'number': number,
      'reference': reference,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'],
      bibleId: map['bibleId'],
      bookId: map['bookId'],
      number: map['number'],
      reference: map['reference'],
    );
  }
}
