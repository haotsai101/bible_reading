// File: download_screen.dart
import 'package:bible_reading/models/bible.dart';
import 'package:flutter/material.dart';
import '../services/bible_service.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late Future<List<BibleGroup>> futureBibleGroups;

  @override
  void initState() {
    super.initState();
    futureBibleGroups = BibleService().fetchBibles(); // Adjusted for BibleGroup
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
            // Build a list of ExpansionTiles for each language group
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
