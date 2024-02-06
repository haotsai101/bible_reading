class Bible {
  final String id;
  final String name;
  final String description;
  final String abbreviation;
  final String language;

  Bible({
    required this.id,
    required this.name,
    required this.description,
    required this.abbreviation,
    required this.language,
  });

  factory Bible.fromJson(Map<String, dynamic> json) {
    return Bible(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? 'No description available',
      abbreviation: json['abbreviation'],
      language: json['language']['name'],
    );
  }
}

class BibleGroup {
  final String language;
  final List<Bible> bibles;

  BibleGroup({required this.language, required this.bibles});
}
