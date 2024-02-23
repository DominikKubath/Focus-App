import 'package:flutter/material.dart';
import '../UI Elements/MenuDrawer.dart';

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  bool isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do Liste'),
      ),
      drawer: MenuDrawer(),
      body: Container(
        child: Center(
          child: Text('ToDoListPage'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Toggle the menu state
          setState(() {
            isMenuOpen = !isMenuOpen;
          });

          // Open or close the drawer based on the state
          if (isMenuOpen) {
            Scaffold.of(context).openDrawer();
          } else {
            Scaffold.of(context).openEndDrawer();
          }
        },
        child: Icon(Icons.menu),
      ),
    );
  }
}
