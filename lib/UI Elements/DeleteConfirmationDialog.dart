import 'package:flutter/material.dart';
import '../Classes/ToDoItem.dart';
import '../FirestoreManager.dart';
import '../Pages/ToDoListPage.dart';

class DeleteConfirmationDialog {
  static Future<bool> show(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ) ??
        false; // Handle null (dialog dismissed) by returning false
  }

  static void DeleteToDoItem(BuildContext context, String id) async {
    bool confirm = await show(context);
    if (confirm) {
      String? userId = await FirestoreManager().ReadUid(context);
      if (userId != null) {
        ToDoItem todo = ToDoItem.empty();
        todo.id = id;
        FirestoreManager().DeleteToDoItem(todo, userId);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ToDoListPage()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }
}
