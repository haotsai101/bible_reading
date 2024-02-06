import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/bible.dart';

class BibleService {
  Future<List<Bible>> fetchBibles() async {
    final apiKey = dotenv.env['API_KEY']; // Access the API key
    final response = await http.get(
      Uri.parse('https://api.scripture.api.bible/v1/bibles'),
      headers: {'api-key': apiKey!, 'Accept': 'application/json'},
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
