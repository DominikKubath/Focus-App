import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Pages/AddFlashCardPage.dart';

import '../Classes/FlashCardDeck.dart';
import '../UI Elements/MenuDrawer.dart';
import '../FirestoreManager.dart';

import 'DeckContentPage.dart';
import 'CreateNewDeckPage.dart';
import 'EditDeckPage.dart';

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
            return Center(child: Text('No flashcards available.'));
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
      return FirestoreManager().GetAllFlashCardDecks(userId);
    } else {
      return [];
    }
  }
}

class CreateNewDeckButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateNewDeckPage()));
        },
        child: Text('Create New Deck'),
      ),
    );
  }
}

class FlashCardDeckItem extends StatelessWidget {
  final FlashCardDeck deck;

  FlashCardDeckItem({required this.deck});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(deck.name),
      subtitle: Text('Number of Cards: ${deck.cardCount}'),
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
                      builder: (context) => AddFlashCardPage(deckId: deck.id)
                  )
              );
            },
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
                  builder: (context) => EditDeckPage(deckId: deck.id)
                  )
              );
            },
          ),
          IconButton(
            icon: Tooltip(
              message: 'Rename',
              child: Icon(Icons.label),
            ),
            onPressed: () {
              _showRenameDialog(context, deck);
            },
          ),
          IconButton(
            icon: Tooltip(
              message: 'Delete',
              child: Icon(Icons.delete),
            ),
            onPressed: () {
              _showDeleteConfirmation(context, deck);
            },
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeckContentPage(id: deck.id),
          ),
        );
      },
    );
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
                        (Route<dynamic> route) => false); // Close the dialog
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
                        (Route<dynamic> route) => false); // Close the dialog
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }
}

