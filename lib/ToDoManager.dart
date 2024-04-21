import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';

import 'Classes/ToDoItem.dart';


class ToDoManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference userCollection = _firestore.collection("user");

  static const String todoCollectionName = "todos";
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
  }
  void MarkToDoAsNotDone(String todoId, String uid) async
  {
    var userDoc = await userCollection.where("uid", isEqualTo: uid).get();
    userCollection.doc(userDoc.docs[0].id).collection("todos").doc(todoId).update({"isDone" : false});
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
  }

}
