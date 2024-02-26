import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToDoItem
{
  late String id;
  late String name;
  late String description;
  late int priority;
  late bool isDone;

  static const String fieldName = "name";
  static const String fieldDescription = "description";
  static const String fieldPriority = "priority";
  static const String fieldIsDone = "isDone";

  //ToDoItem(this.name, this.description, this.priority, {this.isDone = false});

  ToDoItem.fromDoc(DocumentSnapshot doc)
  {
    id = doc.id;

    name = doc[ToDoItem.fieldName];
    description = doc[ToDoItem.fieldDescription];
    priority = doc[ToDoItem.fieldPriority];
    isDone = doc[ToDoItem.fieldIsDone];
  }

  ToDoItem.empty();

  Map<String, dynamic> ToMap()
  {
    return{
      ToDoItem.fieldName : name,
      ToDoItem.fieldDescription : description,
      ToDoItem.fieldPriority : priority,
      ToDoItem.fieldIsDone : isDone
    };
  }
}