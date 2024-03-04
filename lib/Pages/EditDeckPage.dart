import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Classes/FlashCardDeck.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';

import '../Classes/FlashCard.dart';


/*class EditDeckPage extends StatefulWidget {
  final String deckId;
  const EditDeckPage({Key? key, required this.deckId}) : super(key: key);

  @override
  _EditDeckPageState createState() => _EditDeckPageState();
}

class _EditDeckPageState extends State<EditDeckPage> {
  late Future<List<FlashCard>> flashcards;
  FlashCard? selectedFlashcard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Deck'),
      ),
      body: FutureBuilder<List<FlashCard>>(
        future: _getFlashCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No flashcards available.'));
          } else {
            List<FlashCard> flashcardList = snapshot.data!;
            TextEditingController frontsideController =
            TextEditingController(text: selectedFlashcard?.frontside ?? "");
            TextEditingController backsideController =
            TextEditingController(text: selectedFlashcard?.backside ?? "");

            return Row(
              children: [
                // Left Side: List of Flashcards
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: flashcardList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(flashcardList[index].frontside),
                        onTap: () {
                          setState(() {
                            selectedFlashcard = flashcardList[index];
                            frontsideController.text =
                                selectedFlashcard?.frontside ?? "";
                            backsideController.text =
                                selectedFlashcard?.backside ?? "";
                          });
                        },
                      );
                    },
                  ),
                ),
                // Right Side: Display Selected Flashcard
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    color: Colors.grey[200],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Flashcard:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          controller: frontsideController,
                          decoration: InputDecoration(
                            labelText: 'Frontside',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                          onChanged: (value) {
                            _updateFlashCardField(
                                selectedFlashcard!.docId, 'frontside', value);
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: backsideController,
                          decoration: InputDecoration(
                            labelText: 'Backside',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 4,
                          onChanged: (value) {
                            _updateFlashCardField(
                                selectedFlashcard!.docId, 'backside', value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<List<FlashCard>> _getFlashCards() async
  {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      return FirestoreManager().GetAllFlashCardsOfDeck(widget.deckId, userId);
    } else {
      return [];
    }
  }

  void _updateFlashCardField(String cardId, String fieldName, String newContent) async {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      FirestoreManager().UpdateFlashCardField(cardId, fieldName, newContent, widget.deckId, userId);
    }
  }
}*/

class EditDeckPage extends StatefulWidget {
  final String deckId;
  final List<FlashCard> flashCards;

  const EditDeckPage({Key? key, required this.deckId, required this.flashCards}) : super(key: key);

  @override
  _EditDeckPageState createState() => _EditDeckPageState();
}

class _EditDeckPageState extends State<EditDeckPage> {
  FlashCard? selectedFlashcard;

  @override
  Widget build(BuildContext context) {
    List<FlashCard> flashcardList = widget.flashCards;

    TextEditingController frontsideController =
    TextEditingController(text: selectedFlashcard?.frontside ?? "");
    TextEditingController backsideController =
    TextEditingController(text: selectedFlashcard?.backside ?? "");

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Deck'),
      ),
      body: Row(
        children: [
          // Left Side: List of Flashcards
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: flashcardList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(flashcardList[index].frontside),
                  onTap: () {
                    setState(() {
                      selectedFlashcard = flashcardList[index];
                      frontsideController.text =
                          selectedFlashcard?.frontside ?? "";
                      backsideController.text =
                          selectedFlashcard?.backside ?? "";
                    });
                  },
                );
              },
            ),
          ),
          // Right Side: Display Selected Flashcard
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Flashcard:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: frontsideController,
                    decoration: InputDecoration(
                      labelText: 'Frontside',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    onChanged: (value) {
                      _updateFlashCardField(
                          selectedFlashcard!.docId, 'frontside', value);
                      selectedFlashcard!.frontside = value;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: backsideController,
                    decoration: InputDecoration(
                      labelText: 'Backside',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    onChanged: (value) {
                      _updateFlashCardField(
                          selectedFlashcard!.docId, 'backside', value);
                      selectedFlashcard!.backside = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateFlashCardField(String cardId, String fieldName, String newContent) async {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      FirestoreManager().UpdateFlashCardField(
          cardId, fieldName, newContent, widget.deckId, userId);
    }
  }
}

