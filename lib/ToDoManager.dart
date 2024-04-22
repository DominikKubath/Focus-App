import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';

import 'Classes/ToDoItem.dart';
import 'Classes/TodoStatistic.dart';


class ToDoManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference userCollection = _firestore.collection("user");

  static const String todoCollectionName = "todos";
  static const String todoStatsCollectionName = "todoStats";
  static const String scoreCollectionName = "scores";

  Future<List<ToDoItem>> GetAllToDos(String uid) async
  {
    var userDocument = await userCollection.where("uid", isEqualTo: uid).get();
    return await userCollection.doc(userDocument.docs[0].id).collection("todos").get().then((value){
      List<ToDoItem> todos = [];
      value.docs.forEach((element) {
        debugPrint("GOT TODO " + element.data().toString());
        todos.add(ToDoItem.fromDoc(element));
      });
      return todos;
    });
  }

  void CreateNewToDo(ToDoItem newItem, String uid) async
  {
    newItem.isDone = false;

    var userDoc = await userCollection.where("uid", isEqualTo: uid).get();
    debugPrint("New ToDo item ID: ${userDoc.docs[0].id}");
    userCollection.doc(userDoc.docs[0].id).collection("todos").add(newItem.ToMap());
    UpdateTodoStats(1, "createdTodos", uid);
  }

  void UpdateToDoItemField(String todoId, String fieldName, String newValue, bool isNumerical, String uid) async
  {
    var userDoc = await userCollection.where("uid", isEqualTo: uid).get();

    if(isNumerical)
    {
      int prio = int.parse(newValue);
      userCollection.doc(userDoc.docs[0].id).collection("todos").doc(todoId).update({fieldName : prio});
    }
    else
    {
      userCollection.doc(userDoc.docs[0].id).collection("todos").doc(todoId).update({fieldName : newValue});
    }
  }

  void MarkToDoAsDone(String todoId, String uid) async
  {
    var userDoc = await userCollection.where("uid", isEqualTo: uid).get();
    userCollection.doc(userDoc.docs[0].id).collection("todos").doc(todoId).update({"isDone" : true});
    UpdateTodoStats(1, "completedThatDay", uid);
  }
  void MarkToDoAsNotDone(String todoId, String uid) async
  {
    var userDoc = await userCollection.where("uid", isEqualTo: uid).get();
    userCollection.doc(userDoc.docs[0].id).collection("todos").doc(todoId).update({"isDone" : false});
    UpdateTodoStats(-1, "completedThatDay", uid);
  }

  void UpdateTodoStats(int count, String fieldName, String uid) async
  {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        TodoStatistic? todayScore = await GetTodaysTodoStats(uid);
        if (todayScore == null) {
          CreateTodaysTodoStatsIfNotExisting(uid, fieldName, count);
        } else {
          int updatedAmount = 0;
          if(fieldName == "createdTodos")
          {
            updatedAmount = todayScore.createdTodos + count;
          }
          else
          {
            updatedAmount = todayScore.completedThatDay + count;
          }
          await userCollection
              .doc(userDoc.id)
              .collection(todoStatsCollectionName)
              .doc(todayScore.docId)
              .update({fieldName: updatedAmount});
        }
      } catch (e) {
        print("Error updating today's score: $e");
      }
    }
  }

  Future<TodoStatistic?> GetTodaysTodoStats(String uid) async
  {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if(userDoc != null)
    {
      try {
        DateTime today = DateTime.now();
        DateTime startOfToday = DateTime(today.year, today.month, today.day);
        QuerySnapshot querySnapshot = await userCollection
            .doc(userDoc.id)
            .collection(todoStatsCollectionName)
            .where(TodoStatistic.dateFieldName, isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
            .where(TodoStatistic.dateFieldName, isLessThan: Timestamp.fromDate(startOfToday.add(Duration(days: 1))))
            .limit(1)
            .get();

        debugPrint(TodoStatistic.fromDoc(querySnapshot.docs.first).docId);
        if (querySnapshot.docs.isNotEmpty) {
          return TodoStatistic.fromDoc(querySnapshot.docs.first);
        } else {
          return null;
        }
      } catch (e) {
        print("Error fetching today's score: $e");
        return null;
      }
    }
  }

  void CreateTodaysTodoStatsIfNotExisting(String uid, String fieldName, int initialAmount) async {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        DateTime startOfToday = DateTime(today.year, today.month, today.day);
        TodoStatistic? todayScore = await GetTodaysTodoStats(uid);
        if (todayScore == null) {
          if(fieldName == "createdTodos")
          {
            await userCollection.doc(userDoc.id).collection(todoStatsCollectionName).add({
              fieldName: initialAmount,
              "completedThatDay" : 0,
              TodoStatistic.dateFieldName: Timestamp.fromDate(startOfToday)
            });
          }
          else
          {
            await userCollection.doc(userDoc.id).collection(todoStatsCollectionName).add({
              fieldName: initialAmount,
              "createdTodos" : 0,
              TodoStatistic.dateFieldName: Timestamp.fromDate(startOfToday)
            });
          }
        }
      } catch (e) {
        print("Error creating today's score: $e");
      }
    }
  }

  void UpdateToDoItem(ToDoItem item, String uid) async
  {
    var userDoc = await userCollection.where("uid", isEqualTo: uid).get();
    userCollection.doc(userDoc.docs[0].id).collection("todos").doc(item.id).update(item.ToMap());
  }

  void DeleteToDoItem(ToDoItem oldItem, String uid) async
  {
    var userDoc = await userCollection.where("uid", isEqualTo: uid).get();
    userCollection.doc(userDoc.docs[0].id).collection("todos").doc(oldItem.id).delete();
    UpdateTodoStats(-1, "createdTodos", uid);
  }

}
