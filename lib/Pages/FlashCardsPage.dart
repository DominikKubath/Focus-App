import 'package:flutter/material.dart';
import '../Classes/FlashCardDeck.dart';
import '../UI Elements/MenuDrawer.dart';
import 'DeckContentPage.dart';
import '../FirestoreManager.dart';

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
            // Display the flashcards using ListView.builder
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                FlashCardDeck deck = snapshot.data![index];
                return ListTile(
                  title: Text(deck.name),
                  subtitle: Text('Number of Cards: NR'),
                  onTap: () {
                    // Handle the tap, navigate to a new screen, etc.
                    // You can use deck.id to pass the selected deck ID
                  },
                );
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

class FlashCardDeckItem extends StatelessWidget {
  late final FlashCardDeck deck;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("Card Decks"),
      onTap: () {
        // Navigate to a new screen and pass the item's ID
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
