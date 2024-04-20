import 'package:flutter/material.dart';
import '../Classes/ToDoItem.dart';
import '../FirestoreManager.dart';
import '../Pages/ToDoListPage.dart';
import '../ToDoManager.dart';

class CreateNewToDoDialog {
  static Future<void> show(BuildContext context) async {
    TextEditingController newToDoNameController = TextEditingController();
    TextEditingController newToDoDescriptionController = TextEditingController();
    TextEditingController newToDoPriorityController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New To-Do'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Enter the title of the to-do:'),
                TextFormField(
                  controller: newToDoNameController,
                  decoration: InputDecoration(
                    hintText: 'Example: Grocery Shopping',
                  ),
                  keyboardType: TextInputType.text,
                ),
                Text('Description:'),
                TextFormField(
                  controller: newToDoDescriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description',
                  ),
                  keyboardType: TextInputType.text,
                ),
                Text('Priority (0-3):'),
                TextFormField(
                  controller: newToDoPriorityController,
                  decoration: InputDecoration(
                    hintText: 'Priority (0-3)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  String? uid = await FirestoreManager().ReadUid(context);
                  ToDoItem todo = ToDoItem.empty();
                  todo.name = newToDoNameController.text;
                  todo.description = newToDoDescriptionController.text;
                  int? priority = int.tryParse(newToDoPriorityController.text);
                  if(priority != null && priority >= 0 && priority <= 3) {
                    todo.priority = priority;
                  }
                  ToDoManager().CreateNewToDo(todo, uid!);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ToDoListPage(),
                    ),
                        (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  // Handle error
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
