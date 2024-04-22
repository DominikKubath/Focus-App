import 'package:cloud_firestore/cloud_firestore.dart';

class FlashCardStatistic
{
  late String docId;
  late Timestamp date;
  late int attemptCount;
  late int learnedCards;

  static const String attemptCountFieldName = "attemptsCount";
  static const String learnedCardsFieldName = "learnedCards";
  static const String dateFieldName = "date";


  FlashCardStatistic.empty();

  FlashCardStatistic.fromDoc(DocumentSnapshot doc)
  {
    docId = doc.id;
    date = doc[dateFieldName];
    attemptCount = doc[attemptCountFieldName];
    learnedCards = doc[learnedCardsFieldName];
  }

  Map<String, dynamic> ToMap()
  {
    return {
      attemptCountFieldName : attemptCount,
      learnedCardsFieldName : learnedCards,
      dateFieldName : date
    };
  }

}