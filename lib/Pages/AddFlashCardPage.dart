import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Classes/FlashCard.dart';

import '../FirestoreManager.dart';
import 'FlashCardsPage.dart';

class AddFlashCardPage extends StatefulWidget {
  final String deckId;

  const AddFlashCardPage({Key? key, required this.deckId}) : super(key: key);

  @override
  _AddFlashCardPageState createState() => _AddFlashCardPageState();
}

class _AddFlashCardPageState extends State<AddFlashCardPage> {
  TextEditingController frontsideController = TextEditingController();
  TextEditingController backsideController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add FlashCard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200.0),
              child: TextField(
                controller: frontsideController,
                decoration: InputDecoration(
                  labelText: 'Frontside',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 20),
                minLines: 4,
                maxLines: null,
              ),
            ),
            SizedBox(height: 24),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200.0),
              child: TextField(
                controller: backsideController,
                decoration: InputDecoration(
                  labelText: 'Backside',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 20),
                minLines: 4,
                maxLines: null,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                String? uid = await FirestoreManager().ReadUid(context);
                FlashCard card = FlashCard.empty();
                card.frontside = frontsideController.text;
                card.backside = backsideController.text;

                // Call AddNewFlashCard method
                var result = await FirestoreManager().AddNewFlashCard(card, widget.deckId, uid!);

                // Check if the result is successful
                if (result != null) {
                  // Show SnackBar with the message "New Card Added!"
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('New Card Added!'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Clear the text fields after adding the card
                  frontsideController.clear();
                  backsideController.clear();
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Something went wrong!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Add FlashCard'),
            ),
          ],
        ),
      ),
    );
  }
}
