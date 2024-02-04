import 'package:bible_reading/screens/download.dart';
import 'package:bible_reading/widgets/custom_drawer_content.dart';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/bible_verse.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class BibleVersion {
  final String name;
  bool isSelected;

  BibleVersion({required this.name, this.isSelected = false});
}

class _MyHomePageState extends State<MyHomePage> {
  final BibleVerse sampleVerse = BibleVerse(
    book: 'Genesis',
    chapter: 1,
    verse: 1,
    text: 'In the beginning, God created the heavens and the earth.',
    version: 'test',
  );
  List<BibleVersion> versions = [
    BibleVersion(name: 'NIV'),
    BibleVersion(name: 'KJV'),
    BibleVersion(name: 'ESV'),
  ];

  String? selectedVersion = 'NIV'; // Default version

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
          PopupMenuButton<BibleVersion>(
            onSelected: (BibleVersion version) {
              setState(() {
                version.isSelected = !version.isSelected;
              });
            },
            itemBuilder: (BuildContext context) {
              return versions.map((BibleVersion version) {
                return CheckedPopupMenuItem<BibleVersion>(
                  value: version,
                  checked: version.isSelected,
                  child: Text(version.name),
                );
              }).toList();
            },
            icon: const Icon(Icons.book), // Icon for the versions dropdown
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
              // Add more options as needed
            ],
            icon: const Icon(Icons.more_vert), // The three dots icon
          ),
        ],
      ),
      drawer: const Drawer(
        child: CustomDrawerContent(),
      ),
      body: Center(
        child: FutureBuilder<List<BibleVerse>>(
          future: DatabaseHelper.getVerses(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].text),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => DatabaseHelper.insertVerse(
            sampleVerse), // Awaiting the async operation
        child: const Icon(Icons.add),
      ),
    );
  }
}
