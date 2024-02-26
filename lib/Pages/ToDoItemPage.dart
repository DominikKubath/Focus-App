import 'package:flutter/material.dart';
import '../UI Elements/MenuDrawer.dart';

class ToDoItemPage extends StatefulWidget {
  final String id;
  const ToDoItemPage({Key? key, required this.id}) : super(key: key);
  @override
  _ToDoItemPageState createState() => _ToDoItemPageState();
}

class _ToDoItemPageState extends State<ToDoItemPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('All ToDos'),
        ),
      drawer: MenuDrawer(),
      body: Container(
        child: Center(
          child: Text('ToDo Item Id: ${widget.id}'),
        ),
      ),
    );
  }

}
