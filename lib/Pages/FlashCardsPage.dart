import 'package:flutter/material.dart';

import '../Classes/FlashCardDeck.dart';
import '../UI Elements/MenuDrawer.dart';
import '../FirestoreManager.dart';

import 'DeckContentPage.dart';
import 'CreateNewDeckPage.dart';

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
  FlashCardDeck deck;

  FlashCardDeckItem({required this.deck});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(deck.name),
      subtitle: Text('Number of Cards: ${deck.cardCount}'),
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
}
