import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Pages/AddFlashCardPage.dart';
import 'package:studienarbeit_focus_app/Pages/FlashCardsStatsPage.dart';

import '../Classes/FlashCardDeck.dart';
import '../Classes/Utils.dart';
import '../UI Elements/MenuDrawer.dart';
import '../FirestoreManager.dart';

import 'DeckContentPage.dart';
import 'CreateNewDeckPage.dart';
import 'EditDeckPage.dart';
import 'FlashCardStudyPage.dart';

class FlashCardDeckItem extends StatefulWidget {
  final FlashCardDeck deck;

  FlashCardDeckItem({required this.deck});

  @override
  _FlashCardDeckItemState createState() => _FlashCardDeckItemState();
}

class _FlashCardDeckItemState extends State<FlashCardDeckItem> {
  late String _selectedSortOption = widget.deck.filterMode;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.deck.name),
      subtitle: Text('Number of Cards: ${widget.deck.cardCount}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Tooltip(
              message: 'Add New Flashcard',
              child: Icon(Icons.add),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFlashCardPage(deckId: widget.deck.id),
                ),
              );
            },
          ),
          DropdownButton<String>(
            icon: Tooltip(
              message: 'Sorting Option',
              child: Icon(Icons.account_tree),
            ),
            value: _selectedSortOption,
            onChanged: (String? newValue) {
              _updateFilterMode(newValue!);
            },
            items: <String>['Default', 'Oldest', 'Newest', 'Hardest']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: Tooltip(
              message: 'Edit',
              child: Icon(Icons.edit),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDeckPage(deckId: widget.deck.id, flashCards: widget.deck.flashCards),
                ),
              );
            },
          ),
          IconButton(
            icon: Tooltip(
              message: 'Statistics',
              child: Icon(Icons.bar_chart),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FlashCardStatPage(deck: widget.deck),
                  ),
              );
            },
          ),
          IconButton(
            icon: Tooltip(
              message: 'Rename',
              child: Icon(Icons.label),
            ),
            onPressed: () {
              _showRenameDialog(context, widget.deck);
            },
          ),
          IconButton(
            icon: Tooltip(
              message: 'Delete',
              child: Icon(Icons.delete),
            ),
            onPressed: () {
              _showDeleteConfirmation(context, widget.deck);
            },
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlashCardStudyPage(flashCards: widget.deck.flashCards, deckId: widget.deck.id),
          ),
        );
      },
    );
  }

  void _updateFilterMode(String newFilter) async {
    var uid = await FirestoreManager().ReadUid(context);
    FirestoreManager().UpdateFilterMode(newFilter, widget.deck, uid!);
    setState(() {
      _selectedSortOption = newFilter;
    });
  }

  void _showDeleteConfirmation(BuildContext context, FlashCardDeck deck) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Deck'),
          content: Text('Are you sure you want to delete ${deck.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                var uid = await FirestoreManager().ReadUid(context);
                FirestoreManager().DeleteFlashCardDeck(deck.id, uid!);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashCardsPage(),
                  ),
                      (Route<dynamic> route) => false,
                ); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, FlashCardDeck deck) {
    TextEditingController newDeckNameController = TextEditingController(text: deck.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename Deck'),
          content: TextField(
            controller: newDeckNameController,
            decoration: InputDecoration(labelText: 'New Deck Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                var uid = await FirestoreManager().ReadUid(context);
                FirestoreManager().RenameFlashCardDeck(newDeckNameController.text, deck, uid!);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashCardsPage(),
                  ),
                      (Route<dynamic> route) => false,
                ); // Close the dialog
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }
}

class FlashCardsPage extends StatefulWidget {
  @override
  _FlashCardsPageState createState() => _FlashCardsPageState();
}

class _FlashCardsPageState extends State<FlashCardsPage> {
  late Future<List<FlashCardDeck>> decks;

  @override
  Widget build(BuildContext context) {
    decks = _getFlashCardDecks();

    return Scaffold(
      appBar: AppBar(
        title: Text('Flash Cards'),
      ),
      drawer: MenuDrawer(),
      body: FutureBuilder<List<FlashCardDeck>>(
        future: decks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while waiting for data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display an error message if an error occurs
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Display a message if there are no flashcards
            return Column(
              children: [
                Container(child: Center(child: Text('No flashcards available.'))),
                Container(child: CreateNewDeckButton())
              ],
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length + 1,
              itemBuilder: (context, index) {
                if (index < snapshot.data!.length) {
                  FlashCardDeck deck = snapshot.data![index];
                  return FlashCardDeckItem(deck: deck);
                } else {
                  return CreateNewDeckButton();
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<List<FlashCardDeck>> _getFlashCardDecks() async {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      var decks = await FirestoreManager().GetAllFlashCardDecks(userId);
      decks.forEach((deck) async {
        print("Current deck: " + deck.id + " Name: " + deck.name);
        deck.flashCards = await FirestoreManager().GetAllFlashCardsOfDeck(deck.id, userId, deck.filterMode);
        print("Fetched FlashCards for ${deck.name}: ${deck.flashCards?[0].docId}");
      });
      return decks;
    } else {
      return [];
    }
  }
}

class CreateNewDeckButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          _showCreateDeckDialog(context);
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.greenAccent),foregroundColor: MaterialStateProperty.all(Colors.white)),
        child: Text('Create New Deck'),
      ),
    );
  }

  void _showCreateDeckDialog(BuildContext context) async {
    TextEditingController newDeckNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter the name of the flashcard deck"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Deck Name"),
              TextFormField(
                controller: newDeckNameController,
                decoration: InputDecoration(
                  hintText: "Example: Vocab Spanish",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                try {
                  String? uid = await FirestoreManager().ReadUid(context);
                  FlashCardDeck deck = FlashCardDeck.empty();
                  deck.name = newDeckNameController.text;

                  // Create new deck and get the updated list
                  List<FlashCardDeck> updatedDecks = await FirestoreManager().CreateNewFlashCardDeck(deck, uid!);

                  Navigator.pop(context); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashCardsPage(),
                    ),
                  );
                } catch (e) {
                  // Handle error
                }
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.greenAccent),foregroundColor: MaterialStateProperty.all(Colors.white)),
              child: Text('Create Deck'),
            ),
          ],
        );
      },
    );
  }
}
