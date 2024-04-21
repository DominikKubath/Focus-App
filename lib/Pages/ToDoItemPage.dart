import 'package:flutter/material.dart';
import '../FirestoreManager.dart';
import '../ToDoManager.dart';
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

class EditToDoItemDialog extends StatefulWidget {
  final String title;
  final String description;
  final int priority;
  final String todoId;

  const EditToDoItemDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.priority,
    required this.todoId,
  }) : super(key: key);

  @override
  _EditToDoItemDialogState createState() => _EditToDoItemDialogState();
}

class _EditToDoItemDialogState extends State<EditToDoItemDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
    _priority = widget.priority;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ToDo Item'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) async {
                _updateToDoItemField('name', value, false);
              },
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) async {
                _updateToDoItemField('description', value, false);
              },
            ),
            DropdownButtonFormField<int>(
              value: _priority,
              items: <DropdownMenuItem<int>>[
                DropdownMenuItem(
                    child: Text('No priority'),
                    value: 0
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('Low'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('High'),
                ),
              ],
              onChanged: (int? value) async {
                if (value != null) {
                  setState(() {
                    _priority = value;
                  });
                  _updateToDoItemField('priority', value.toString(), true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateToDoItemField(String fieldName, String newValue, bool isNumerical) async {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      ToDoManager().UpdateToDoItemField(widget.todoId, fieldName, newValue, isNumerical, userId);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}






