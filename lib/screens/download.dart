import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/bible.dart'; // Assuming you have a Bible model

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late Future<List<Bible>> futureBibles;

  Future<List<Bible>> fetchBibles() async {
    final response = await http.get(
      Uri.parse('https://api.scripture.api.bible/v1/bibles'),
      headers: {'api-key': dotenv.env['API_KEY']!},
    );

    if (response.statusCode == 200) {
      List<dynamic> biblesJson = json.decode(response.body)['data'];
      return biblesJson.map((json) => Bible.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Bibles');
    }
  }

  @override
  void initState() {
    super.initState();
    futureBibles = fetchBibles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Bible Versions'),
      ),
      body: FutureBuilder<List<Bible>>(
        future: futureBibles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].name),
                  subtitle: Text(snapshot.data![index].description),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
