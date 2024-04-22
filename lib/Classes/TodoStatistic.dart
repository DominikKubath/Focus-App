import 'package:cloud_firestore/cloud_firestore.dart';

class TodoStatistic
{
  late String docId;
  late Timestamp date;
  late int createdTodos;
  late int completedThatDay;

  static const String createdTodosFieldName = "createdTodos";
  static const String completedTodosFieldName = "completedThatDay";
  static const String dateFieldName = "date";


  TodoStatistic.empty();

  TodoStatistic.fromDoc(DocumentSnapshot doc)
  {
    docId = doc.id;
    date = doc[dateFieldName];
    createdTodos = doc[createdTodosFieldName];
    completedThatDay = doc[completedTodosFieldName];
  }

  Map<String, dynamic> ToMap()
  {
    return {
      createdTodosFieldName : createdTodos,
      completedTodosFieldName : completedThatDay,
      dateFieldName : date
    };
  }

}