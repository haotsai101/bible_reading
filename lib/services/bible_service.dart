import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bible.dart';

class BibleService {
  Future<List<Bible>> fetchBibles() async {
    final response = await http.get(
      Uri.parse('https://api.scripture.api.bible/v1/bibles'),
      // Make sure to include your API key in the header
      headers: {'api-key': 'YOUR_API_KEY_HERE'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> biblesJson = data['data'];

      return biblesJson.map((json) => Bible.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Bibles');
    }
  }
}
