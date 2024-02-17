import 'dart:io';

import 'package:bible_reading/db/database_helper.dart';
import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/services/bible_service.dart';
import 'package:bible_reading/services/file_parsing_service.dart';
import 'package:bible_reading/services/reading_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  late Future<List<BibleGroup>> futureBibleGroups;
  final BibleService bibleService = BibleService();
  List<Bible> localBibles = [];

  @override
  void initState() {
    super.initState();
    futureBibleGroups = bibleService.fetchBibles();
    DatabaseHelper.getBibles().then((bibles) => {
          setState((() {
            localBibles = bibles;
          }))
        });
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
      ReadingManager().addBibleId(bible.id);
      Navigator.pop(
          context); // Go back to the home screen after download completion
    } catch (e) {
      Navigator.pop(context); // Dismiss the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download Bible: $e')),
      );
    }
  }

  Future<void> _pickAndProcessFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      try {
        File file = File(result.files.single.path!);
        Bible bible = await parseAndSaveVerses(file.path);
        ReadingManager().addBibleId(bible.id);
        Navigator.pop(
            context); // Go back to the home screen after download completion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse Bible: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Bible Versions'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: ExpansionTile(
              initiallyExpanded: true,
              title: const Text(
                'Downloaded',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: localBibles
                  .map((bible) => ListTile(
                        title: Text(bible.name),
                        trailing: const Icon(Icons.check, color: Colors.green),
                        tileColor: Colors.grey[200],
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            flex: 4,
            child: FutureBuilder<List<BibleGroup>>(
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
                          bool isDownloaded = localBibles.contains(bible);
                          return ListTile(
                            title: Text(bible.name),
                            subtitle: Text(bible.description),
                            trailing: isDownloaded
                                ? const Icon(Icons.check, color: Colors.green)
                                : null, // Add a check icon if downloaded
                            onTap: isDownloaded
                                ? null
                                : () => _downloadBible(
                                    bible), // Disable onTap if downloaded
                            tileColor: isDownloaded
                                ? Colors.grey[200]
                                : null, // Change color if downloaded
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndProcessFile,
        tooltip: 'Add Bible Text File',
        child: const Icon(Icons.add),
      ),
    );
  }
}
