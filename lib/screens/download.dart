import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/services/bible_service.dart';
import 'package:flutter/material.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late Future<List<BibleGroup>> futureBibleGroups;
  final BibleService bibleService = BibleService();

  @override
  void initState() {
    super.initState();
    futureBibleGroups = bibleService.fetchBibles();
  }

  void _downloadBible(Bible bible) async {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close the dialog
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Downloading..."),
              ],
            ),
          ),
        );
      },
    );

    try {
      await bibleService
          .downloadBible(bible); // Make sure this is the correct parameter
      Navigator.pop(context); // Dismiss the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download completed for Bible ID: ${bible.id}')),
      );
    } catch (e) {
      Navigator.pop(context); // Dismiss the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download Bible: $e')),
      );
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
                          _downloadBible(bible), // Updated onTap callback
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
