import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/models/book.dart';
import 'package:bible_reading/services/bible_service.dart';
import 'package:flutter/material.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late Future<List<BibleGroup>> futureBibleGroups;
  final BibleService bibleService = BibleService();

  @override
  void initState() {
    super.initState();
    futureBibleGroups = bibleService.fetchBibles();
  }

  void _printBooks(String bibleId) async {
    try {
      List<Book> books = await bibleService.fetchBooks(bibleId);
      // Here you can replace print with any other logic you'd like to apply to the books
      for (var book in books) {
        print('${book.name}: ${book.nameLong}');
      }
    } catch (e) {
      print('Failed to load books: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Bible Versions'),
      ),
      body: FutureBuilder<List<BibleGroup>>(
        future: futureBibleGroups,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final group = snapshot.data![index];
                return ExpansionTile(
                  title: Text(group.language),
                  children: group.bibles.map((bible) {
                    return ListTile(
                      title: Text(bible.name),
                      subtitle: Text(bible.description),
                      onTap: () =>
                          _printBooks(bible.id), // Add onTap callback here
                    );
                  }).toList(),
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
