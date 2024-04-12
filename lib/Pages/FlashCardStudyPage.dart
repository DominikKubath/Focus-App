import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';

import '../Classes/Attempt.dart';
import '../Classes/FlashCard.dart';

class FlashCardStudyPage extends StatefulWidget {
  final List<FlashCard> flashCards;
  final String deckId;

  const FlashCardStudyPage({Key? key, required this.flashCards, required this.deckId}) : super(key: key);

  @override
  _FlashCardStudyPageState createState() => _FlashCardStudyPageState();
}

class _FlashCardStudyPageState extends State<FlashCardStudyPage> {
  PageController _pageController = PageController();
  bool showBackside = false;
  late FlashCard currentCard;
  late Timestamp startOfAttempt;
  late Timestamp endOfAttempt;
  late int globalIndex;

  @override
  Widget build(BuildContext context) {
    startOfAttempt = Timestamp.now();
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (RawKeyEvent keyEvent) {
        if (keyEvent is RawKeyDownEvent) {
          if (keyEvent.logicalKey == LogicalKeyboardKey.space) {
            setState(() {
              showBackside = !showBackside;
            });
          } else if (showBackside) {
            if (keyEvent.logicalKey == LogicalKeyboardKey.digit1) {
              _handleResponse('Easy');
            } else if (keyEvent.logicalKey == LogicalKeyboardKey.digit2) {
              _handleResponse('Good');
            } else if (keyEvent.logicalKey == LogicalKeyboardKey.digit3) {
              _handleResponse('Hard');
            } else if (keyEvent.logicalKey == LogicalKeyboardKey.digit4) {
              _handleResponse('Repeat');
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('FlashCard Study'),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: widget.flashCards.length + 1, // Add 1 for the "No more cards" page
          itemBuilder: (context, index) {
            if (index < widget.flashCards.length) {
              globalIndex = index;
              currentCard = widget.flashCards[index];
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 400, // Set a fixed height for the container
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical, // Set the scroll direction to vertical
                        child: Container(
                          padding: EdgeInsets.all(16.0), // Add padding to the container
                          child: Text(
                            showBackside ? currentCard.backside : currentCard.frontside,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (!showBackside)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showBackside = !showBackside;
                          });
                        },
                        child: Column(
                          children: [
                            Text('Reveal Backside'),
                            SizedBox(height: 4),
                            Text('Press Space', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    SizedBox(height: 20),
                    if (showBackside)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ResponseButton('Easy', '1', () => _handleResponse('Easy')),
                          _ResponseButton('Good', '2', () => _handleResponse('Good')),
                          _ResponseButton('Hard', '3', () => _handleResponse('Hard')),
                          _ResponseButton('Repeat', '4', () => _handleResponse('Repeat')),
                        ],
                      ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No more cards.'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Return to the previous page
                      },
                      child: Text('Return'),
                    ),
                  ],
                ),
              );
            }
          },
          onPageChanged: (index) {
            setState(() {
              showBackside = false;
            });
          },
        ),
      ),
    );
  }

  void _handleResponse(String response) async {
    String? userId = await FirestoreManager().ReadUid(context);
    print('User responded with: $response');

    Attempt newAttempt = Attempt.empty();
    newAttempt.attemptStart = startOfAttempt;
    newAttempt.attemptEnd = Timestamp.now();
    newAttempt.status = LastStatus.values.firstWhere(
            (status) => status.name.toString() == response,
        orElse: () => LastStatus.New);
    currentCard.lastStatus = newAttempt.status;
    currentCard.lastStudied = Timestamp.now();

    if(response == 'Repeat')
    {
      widget.flashCards.add(widget.flashCards[globalIndex]);
    }

    FirestoreManager().UpdateFlashCardStatusAndLastStudied(currentCard, widget.deckId, userId!);
    FirestoreManager().AddFlashCardAttempt(newAttempt, widget.deckId, currentCard.docId, userId);
    _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.ease);
  }
}

class _ResponseButton extends StatelessWidget {
  final String label;
  final String keyLabel;
  final VoidCallback onPressed;

  const _ResponseButton(this.label, this.keyLabel, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Column(
        children: [
          Text(label),
          SizedBox(height: 4),
          Text('Press $keyLabel', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
