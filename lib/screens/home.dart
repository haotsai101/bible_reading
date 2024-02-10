import 'package:bible_reading/db/database_helper.dart';
import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/models/verse.dart';
import 'package:bible_reading/screens/download.dart';
import 'package:bible_reading/widgets/custom_drawer_content.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Verse>> futureVerses;
  late Future<List<Bible>> futureVersions;

  @override
  void initState() {
    super.initState();
    // Assuming 'getVersesByChapter' accepts a list of bibleIds, a bookId, and a chapterId
    futureVerses = DatabaseHelper.getVersesByChapter(
        ['de4e12af7f28f599-02'], 'GEN', 'GEN.intro');
    futureVersions = DatabaseHelper.getBibles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bible"),
        backgroundColor: Colors.blue,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: <Widget>[
          FutureBuilder<List<Bible>>(
            future: futureVersions,
            builder:
                (BuildContext context, AsyncSnapshot<List<Bible>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return PopupMenuButton<Bible>(
                  onSelected: (Bible version) {
                    // Handle the version selection
                  },
                  itemBuilder: (BuildContext context) {
                    return snapshot.data!.map((Bible version) {
                      return PopupMenuItem<Bible>(
                        value: version,
                        child: Text(version.abbreviation),
                      );
                    }).toList();
                  },
                  icon: const Icon(Icons.book),
                );
              } else {
                // Display a placeholder or an empty widget if versions are not loaded yet
                return Container();
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'download') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DownloadScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'download',
                child: Text('Download'),
              ),
              // Additional options can be added here
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      drawer: const Drawer(
        child: CustomDrawerContent(),
      ),
      body: FutureBuilder<List<Verse>>(
        future: futureVerses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                      'No Bible version downloaded, please download one first.'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Verse verse = snapshot.data![index];
                return ListTile(
                  title: Text(verse.content),
                  subtitle: Text(
                      'Bible ID: ${verse.bibleId}, Verse: ${verse.number}'),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => DatabaseHelper.insertVerse(
      //       sampleVerse), // Await the async operation
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
