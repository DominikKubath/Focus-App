import 'package:cloud_firestore/cloud_firestore.dart';

class Score
{
  late String docId;
  late Timestamp date;
  late int amount;

  static const String amountFieldName = "value";
  static const String dateFieldName = "date";

  Score.empty();

  Score.fromDoc(DocumentSnapshot doc)
  {
    docId = doc.id;
    date = doc[dateFieldName];
    amount = doc[amountFieldName];
  }

  Map<String, dynamic> ToMap()
  {
    return {
      amountFieldName : amount,
      dateFieldName : date
    };
  }

}