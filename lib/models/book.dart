class Book {
  final String id;
  final String bibleId;
  final String abbreviation;
  final String name;
  final String nameLong;

  Book({
    required this.id,
    required this.bibleId,
    required this.abbreviation,
    required this.name,
    required this.nameLong,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      bibleId: json['bibleId'],
      abbreviation: json['abbreviation'],
      name: json['name'],
      nameLong: json['nameLong'],
    );
  }
}
