import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studienarbeit_focus_app/Classes/FlashCard.dart';

class FlashCardDeck
{
  late String id;
  late String name;
  late int cardCount;
  late String filterMode;
  late List<FlashCard> flashCards;

  static const String fieldName = "deckname";
  static const String fieldCardCount = "cardCount";
  static const String fieldFilter = "filter";

  FlashCardDeck.fromDoc(DocumentSnapshot doc)
  {
    id = doc.id;
    name = doc[FlashCardDeck.fieldName];
    cardCount = doc[FlashCardDeck.fieldCardCount];
    try {
      filterMode = doc[FlashCardDeck.fieldFilter];
    } catch (e) {
      filterMode = 'Default';
    }
  }

  FlashCardDeck.empty();

  Map<String, dynamic> ToMap()
  {
    return{
      FlashCardDeck.fieldName : name,
      FlashCardDeck.fieldCardCount : cardCount,
      FlashCardDeck.fieldFilter : filterMode
    };
  }
}