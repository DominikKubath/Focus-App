import 'package:flutter/material.dart';
import '../Classes/ToDoItem.dart';
import '../FirestoreManager.dart';
import '../Pages/ToDoListPage.dart';

class EditToDoDialog {
  static void showEditDialog(BuildContext context, String title, String description, String id, int priority) {
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController descriptionController = TextEditingController(text: description);
    int currentPriority = priority;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit ToDo Item'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(hintText: "Title"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(hintText: "Description"),
                    ),
                    DropdownButton<int>(
                      value: currentPriority,
                      items: const [
                        DropdownMenuItem(child: Text('No priority'), value: 0),
                        DropdownMenuItem(child: Text('Low priority'), value: 1),
                        DropdownMenuItem(child: Text('Medium priority'), value: 2),
                        DropdownMenuItem(child: Text('High priority'), value: 3),
                      ],
                      onChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            currentPriority = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    String? userId = await FirestoreManager().ReadUid(context);
                    if (userId != null) {
                      ToDoItem todo = ToDoItem.empty();
                      todo.id = id;
                      todo.name = titleController.text;
                      todo.description = descriptionController.text;
                      todo.priority = currentPriority;
                      todo.isDone = false;

                      FirestoreManager().UpdateToDoItem(todo, userId);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => ToDoListPage()),
                            (Route<dynamic> route) => false,
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
