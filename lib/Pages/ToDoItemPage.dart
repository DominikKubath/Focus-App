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
        title: const Text('ToDo Details'),
      ),
      drawer: MenuDrawer(),
      body: Center(
        child: Text('ToDo Item Id: ${widget.id}'),
      ),
    );
  }
}



