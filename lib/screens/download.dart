import 'dart:io';

import 'package:bible_reading/db/database_helper.dart';
import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/services/bible_service.dart';
import 'package:bible_reading/services/file_parsing_service.dart';
import 'package:bible_reading/services/reading_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DownloadScreen extends StatefulWidget {
  final updateData;

  const DownloadScreen({Key? key, required this.updateData}) : super(key: key);

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
      await ReadingManager().addBibleId(bible.id);
      widget.updateData();
      Navigator.pop(
          context); // Go back to the home screen after download completion
    } catch (e) {
      Navigator.pop(context); // Dismiss the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download Bible: $e')),
      );
    }
  }

  void _deleteBible(String bibleId) async {
    // Show confirmation dialog before deletion
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content:
                  const Text('Are you sure you want to delete this Bible?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmDelete) {
      await DatabaseHelper.deleteBible(bibleId);
      await ReadingManager().removeBibleId(bibleId);
      widget
          .updateData(); // Assuming this method updates the localBibles list and refreshes the UI
      DatabaseHelper.getBibles().then((bibles) => {
            setState((() {
              localBibles = bibles;
            }))
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bible deleted successfully')),
      );
    }
  }

// Modify ListTile for downloaded bibles to include a GestureDetector or InkWell for long press
  Widget _downloadedBibleTile(Bible bible) {
    return InkWell(
      onLongPress: () => _deleteBible(bible.id),
      child: ListTile(
        title: Text(bible.name),
        trailing: const Icon(Icons.check, color: Colors.green),
        tileColor: Colors.grey[200],
      ),
    );
  }

  Future<void> _pickAndProcessFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        try {
          File file = File(result.files.single.path!);
          Bible bible = await parseAndSaveVerses(file.path);
          await ReadingManager().addBibleId(bible.id);
          widget.updateData();
          Navigator.pop(
              context); // Go back to the home screen after download completion
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to parse Bible: $e')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied for accessing file picker.')),
      );
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
                  .map((bible) => _downloadedBibleTile(bible))
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
