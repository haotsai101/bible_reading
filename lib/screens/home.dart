import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/models/verse.dart';
import 'package:bible_reading/screens/download.dart';
import 'package:bible_reading/services/reading_manager.dart';
import 'package:bible_reading/widgets/custom_drawer_content.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Verse>> futureVerses = Future.value([]);
  late Future<List<Bible>> futureVersions = Future.value([]);
  Map<String, Bible> biblesMap = {}; // Map to hold Bible ID to Bible object
  String title = 'Bible';

  @override
  initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    futureVerses = ReadingManager().getVersesByChapter();
    futureVersions = ReadingManager().getBibles().then((bibles) {
      // Initialize the map of Bible IDs to Bible objects
      biblesMap = {for (var bible in bibles) bible.id: bible};
      return bibles;
    });
    ReadingManager().getChapter().then((c) => {
          ReadingManager().getBook().then((b) => {
                if (b != null && c != null)
                  {setState(() => title = '${b.name} ${c.number}')}
              })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                  onSelected: (Bible version) async {
                    // Handle the version selection
                    if (ReadingManager().currentBibleIds.contains(version.id)) {
                      await ReadingManager().removeBibleId(version.id);
                    } else {
                      await ReadingManager().addBibleId(version.id);
                    }
                    setState(() {
                      fetchData();
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return snapshot.data!.map((Bible version) {
                      return CheckedPopupMenuItem<Bible>(
                        value: version,
                        checked: ReadingManager()
                            .currentBibleIds
                            .contains(version.id),
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
      drawer: Drawer(
        child: CustomDrawerContent(
          updateData: fetchData, // Pass the function directly
        ),
      ),
      body: FutureBuilder<List<Verse>>(
        future: futureVerses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                    'No Bible downloaded/selected, please download/select one first.'),
              ));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Verse verse = snapshot.data![index];
                return ListTile(
                  title: Text('${verse.number} ${verse.content}'),
                  subtitle: biblesMap.length > 1
                      ? Text(
                          'Bible: ${biblesMap[verse.bibleId]?.abbreviation ?? 'Unknown'}')
                      : null, // Conditional display based on the number of items in biblesMap
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
