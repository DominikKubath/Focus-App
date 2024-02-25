import 'package:cloud_firestore/cloud_firestore.dart';

class FlashCardDeck
{
  late String id;
  late String name;
  late int cardCount;

  static const String fieldName = "deckname";
  static const String fieldCardCount = "cardCount";

  FlashCardDeck.fromDoc(DocumentSnapshot doc)
  {
    id = doc.id;
    name = doc[FlashCardDeck.fieldName];
    cardCount = doc[FlashCardDeck.fieldCardCount];
  }

  FlashCardDeck.empty();

  Map<String, dynamic> ToMap()
  {
    return{
      FlashCardDeck.fieldName : name,
      FlashCardDeck.fieldCardCount : cardCount
    };
  }
}