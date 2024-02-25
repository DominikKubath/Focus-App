import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studienarbeit_focus_app/Classes/FlashCardDeck.dart';
import 'package:studienarbeit_focus_app/Pages/FlashCardsPage.dart';

import '../Classes/UserInfo.dart';
import '../FirestoreManager.dart';

class CreateNewDeckPage extends StatefulWidget {
  @override
  _CreateNewDeckPageState createState() => _CreateNewDeckPageState();
}

class _CreateNewDeckPageState extends State<CreateNewDeckPage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController newDeckNameController = TextEditingController();
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 60),
              child: Text("Enter the name of the flashcard deck",
                style: GoogleFonts.montserrat(fontSize: 48),
                textAlign: TextAlign.center,),),
            Container(
              width: screenWidth,
              margin: EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Text(
                  "Deck Name", style: GoogleFonts.montserrat(fontSize: 14)),),
            Container(
                margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                child: TextFormField(controller: newDeckNameController,
                  decoration: InputDecoration(hintText: "Example: Vocab Spanish",
                      hintStyle: GoogleFonts.montserrat(color: Colors.grey)),
                  keyboardType: TextInputType.text,)),
            Container(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    try
                    {
                      String? uid = await FirestoreManager().ReadUid(context);
                      FlashCardDeck deck = FlashCardDeck.empty();
                      deck.name = newDeckNameController.text;
                      FirestoreManager().CreateNewFlashCardDeck(deck, uid!);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashCardsPage(),
                          ),
                              (Route<dynamic> route) => false);
                    } catch (e) {

                    }
                  },
                  child: Text('Create Deck'),
                )
            ),
          ],
        )
    );
  }
}

