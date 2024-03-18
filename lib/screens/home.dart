import 'package:bible_reading/db/database_helper.dart';
import 'package:bible_reading/models/bible.dart';
import 'package:bible_reading/models/verse.dart';
import 'package:bible_reading/screens/download.dart';
import 'package:bible_reading/services/reading_manager.dart';
import 'package:bible_reading/widgets/custom_drawer_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late Future<List<Verse>> futureVerses = Future.value([]);
  late Future<List<Bible>> futureVersions = Future.value([]);
  Map<String, Bible> biblesMap = {}; // Map to hold Bible ID to Bible object
  String title = 'Bible';

  late Offset _tapPosition;

  @override
  initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    futureVerses = ReadingManager().getVersesByChapter();
    futureVersions = ReadingManager().getBibles().then((bibles) {
      // Initialize the map of Bible IDs to Bible objects
      biblesMap = {for (var bible in bibles) bible.id: bible};
      return bibles;
    });
    ReadingManager().getChapter().then((c) => {
          ReadingManager().getBook().then((b) => {
                if (b != null &&
                    c != null &&
                    ReadingManager().currentBibleIds.isNotEmpty)
                  {setState(() => title = '${b.abbreviation} ${c.number}')}
                else if (ReadingManager().currentBibleIds.isEmpty)
                  {setState(() => title = 'Bible')}
              })
        });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      futureVerses = ReadingManager().getVersesByChapter();
      futureVersions = ReadingManager().getBibles().then((bibles) {
        // Initialize the map of Bible IDs to Bible objects
        biblesMap = {for (var bible in bibles) bible.id: bible};
        return bibles;
      });
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
                    _fetchData();
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
                      builder: (context) =>
                          DownloadScreen(updateData: _fetchData)),
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
          updateData: _fetchData, // Pass the function directly
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: GestureDetector(
          onHorizontalDragEnd: (DragEndDetails details) async {
            // Determine swipe direction
            if (details.primaryVelocity! > 0) {
              // User swiped Right - Load previous chapter
              // Here, you need to implement logic to determine the previous chapter ID
              await ReadingManager().goToPreviousChapter();
              _fetchData();
            } else if (details.primaryVelocity! < 0) {
              // User swiped Left - Load next chapter
              // Here, you need to implement logic to determine the next chapter ID
              await ReadingManager().goToNextChapter();
              _fetchData();
            }
          },
          child: FutureBuilder<List<Verse>>(
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
                    Color? bgColor = verse.highlighted
                        ? Colors.yellow
                        : null; // Highlighted verses have yellow background
                    TextStyle textStyle = TextStyle(
                      backgroundColor:
                          bgColor, // Apply background color directly to text for highlighting
                    );

                    IconData? leadingIcon = verse.marked
                        ? Icons.bookmark
                        : null; // Marked verses show a bookmark icon

                    return GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        _tapPosition = details.globalPosition;
                      },
                      child: ListTile(
                        leading: verse.marked
                            ? GestureDetector(
                                onTap: () async {
                                  // Implement logic to unmark the verse
                                  await DatabaseHelper.markUnmarkVerse(verse.id,
                                      false); // Assuming you have this method in your DatabaseHelper
                                  _fetchData();
                                },
                                child: Icon(Icons.bookmark, color: Colors.blue),
                              )
                            : null,
                        title: Text('${verse.number} ${verse.content}',
                            style: textStyle),
                        subtitle: ReadingManager().currentBibleIds.length > 1
                            ? Text(
                                'Bible: ${biblesMap[verse.bibleId]?.abbreviation ?? 'Unknown'}')
                            : null, // Conditional display based on the number of items in biblesMap
                        onLongPress: () async {
                          final RenderBox overlay = Overlay.of(context)
                              .context
                              .findRenderObject() as RenderBox;

                          final selectedItem = await showMenu(
                            context: context,
                            position: RelativeRect.fromRect(
                                _tapPosition &
                                    const Size(
                                        40, 40), // smaller rect, the touch area
                                Offset.zero &
                                    overlay
                                        .size // Bigger rect, the entire screen
                                ),
                            items: [
                              const PopupMenuItem(
                                value: 'copy',
                                child: Text('Copy'),
                              ),
                              const PopupMenuItem(
                                value: 'highlight',
                                child: Text('Highlight'),
                              ),
                              const PopupMenuItem(
                                value: 'mark',
                                child: Text('Mark'),
                              ),
                            ],
                          );

                          // Handle the action based on the selected item
                          switch (selectedItem) {
                            case 'copy':
                              // Copy verse to clipboard
                              Clipboard.setData(ClipboardData(
                                  text: '${verse.number} ${verse.content}'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Copied to clipboard')));
                              break;
                            case 'highlight':
                              // Call DatabaseHelper to toggle highlight status
                              await DatabaseHelper.highlightUnhighlightVerse(
                                  verse.id, !verse.highlighted);
                              _fetchData(); // Refresh data
                              break;
                            case 'mark':
                              // Call DatabaseHelper to toggle mark status
                              await DatabaseHelper.markUnmarkVerse(
                                  verse.id, !verse.marked);
                              _fetchData(); // Refresh data
                              break;
                          }
                        },
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
