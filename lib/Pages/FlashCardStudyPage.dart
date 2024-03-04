import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Classes/FlashCard.dart';

class FlashCardStudyPage extends StatefulWidget {
  final List<FlashCard> flashCards;

  const FlashCardStudyPage({Key? key, required this.flashCards}) : super(key: key);

  @override
  _FlashCardStudyPageState createState() => _FlashCardStudyPageState();
}

class _FlashCardStudyPageState extends State<FlashCardStudyPage> {
  PageController _pageController = PageController();
  bool showBackside = false;

  @override
  Widget build(BuildContext context) {
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
              FlashCard currentFlashcard = widget.flashCards[index];
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showBackside ? currentFlashcard.backside : currentFlashcard.frontside,
                      style: TextStyle(fontSize: 24),
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
              // Display a message for no more cards
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

  void _handleResponse(String response) {
    print('User responded with: $response');
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