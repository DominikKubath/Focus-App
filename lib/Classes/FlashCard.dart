
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

enum LastStatus{
  Repeat,
  Hard,
  Good,
  Easy,
  New
}

class FlashCard
{
  late String docId;
  late String frontside;
  late String backside;
  late LastStatus lastStatus;
  late Timestamp lastStudied;

  static const String fieldFrontside = "frontside";
  static const String fieldBackside = "backside";
  static const String fieldLastStatus = "lastStatus";
  static const String fieldLastStudied = "lastStudied";

  FlashCard.empty();

  FlashCard.fromDoc(DocumentSnapshot doc)
  {
    docId = doc.id;
    frontside = doc[FlashCard.fieldFrontside];
    backside = doc[FlashCard.fieldBackside];
    lastStatus = LastStatus.values.firstWhere(
          (status) => status.toString() == 'LastStatus.${doc[FlashCard.fieldLastStatus]}',
      orElse: () => LastStatus.New,
    );
    lastStudied = doc[FlashCard.fieldLastStudied];
  }
  FlashCard.fromMap(Map<String, dynamic> doc) {
    docId = doc['id'];
    frontside = doc[fieldFrontside];
    backside = doc[fieldBackside];
    lastStatus = LastStatus.values.firstWhere(
            (status) => status.toString() == doc[fieldLastStatus],
        orElse: () => LastStatus.New);
    lastStudied = doc[fieldLastStudied];
  }

  Map<String, dynamic> ToMap()
  {
    return{
      fieldFrontside : frontside,
      fieldBackside : backside,
      fieldLastStatus : lastStatus.name.toString(),
      fieldLastStudied : lastStudied
    };
  }

}

