import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/UI%20Elements/ToDoItemWidget.dart';
import '../ToDoManager.dart';
import '../UI Elements/MenuDrawer.dart';
import '../Classes/ToDoItem.dart';

import '../FirestoreManager.dart';
import 'CreateNewToDoItem.dart'; // Update import to the new dialog file

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  late Future<List<ToDoItem>> todos;

  bool isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    todos = _getToDoItems();

    return Scaffold(
      appBar: AppBar(
        title: Text('All ToDos'),
      ),
      drawer: MenuDrawer(),
      body: FutureBuilder<List<ToDoItem>>(
        future: todos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while waiting for data
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display an error message if an error occurs
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Display a message if there are no todos and the CreateNewToDoButton
            return Column(
              children: [
                Expanded(
                  child: Center(child: Text('No todos available.')),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 70, right: 70, bottom: 10),
                  child: CreateNewToDoButton(),
                ),
              ],
            );
          } else {
            // Display the todos using ListView.builder
            return ListView.builder(
              itemCount: snapshot.data!.length + 1, // Increase itemCount by 1 to accommodate the button
              itemBuilder: (context, index) {
                if (index < snapshot.data!.length) {
                  // If index is within the range of the data list, display ToDoItemWidget
                  ToDoItem item = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 30, left: 70, right: 70, bottom: 10),
                    child: ToDoItemWidget(
                      title: item.name,
                      id: item.id,
                      description: item.description,
                      priority: item.priority,
                    ),
                  );
                  // display following padding with child: CreateNewToDoButton() even without ToDoItemWidget
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 50, left: 70, right: 70, bottom: 10),
                    child: CreateNewToDoButton(),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<List<ToDoItem>> _getToDoItems() async {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      return ToDoManager().GetAllToDos(userId);
    } else {
      return [];
    }
  }
}

class CreateNewToDoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          CreateNewToDoDialog.show(context); // Call the show method of the dialog
        },
        child: Text('Create new ToDo'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.greenAccent),foregroundColor: MaterialStateProperty.all(Colors.white)),
      ),
    );
  }
}