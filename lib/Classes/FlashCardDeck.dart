import 'package:cloud_firestore/cloud_firestore.dart';

class FlashCardDeck
{
  late String id;
  late String name;

  static const String fieldName = "deckname";

  FlashCardDeck.fromDoc(DocumentSnapshot doc)
  {
    id = doc.id;
    name = doc[FlashCardDeck.fieldName];
  }

  Map<String, dynamic> ToMap()
  {
    return{
      FlashCardDeck.fieldName : name
    };
  }
}