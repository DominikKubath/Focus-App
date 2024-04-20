import 'package:flutter/material.dart';
import '../FirestoreManager.dart';
import '../Pages/ToDoItemPage.dart';
import '../Classes/ToDoItem.dart';
import '../Constants/ColorPalette.dart';
import '../Classes/Utils.dart';
import '../ScoreManager.dart';
import '../ToDoManager.dart';
import 'EditToDoDialog.dart';
import '../UI Elements/DeleteConfirmationDialog.dart';

class ToDoItemWidget extends StatefulWidget {
  final String title;
  final String description;
  final String id;
  final int priority;

  const ToDoItemWidget({
    Key? key,
    required this.title,
    required this.id,
    required this.description,
    required this.priority,
  }) : super(key: key);

  @override
  _ToDoItemWidgetState createState() => _ToDoItemWidgetState();
}

class _ToDoItemWidgetState extends State<ToDoItemWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          CheckBoxButton(
            todoId: widget.id,
            isChecked: isChecked,
            onChanged: (value) {
              setState(() {
                isChecked = value;
              });
            },
          ),
          const SizedBox(width: 10),
          Text(
            widget.title,
            style: isChecked ? TextStyle(decoration: TextDecoration.lineThrough) : null,
          ),
        ],
      ),
      subtitle: Text(widget.description),
      contentPadding: const EdgeInsets.only(top: 5, left: 70, right: 70, bottom: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      tileColor: ColorPalette.bgColor,
      leading: Container(
        height: 10,
        width: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Utils.getPriorityColor(widget.priority),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: ColorPalette.funcBlue),
            onPressed: () => EditToDoDialog.showEditDialog(context, widget.title, widget.description, widget.id, widget.priority),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: ColorPalette.funcBlue),
            onPressed: () => DeleteConfirmationDialog.DeleteToDoItem(context, widget.id),
          ),
        ],
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ToDoItemPage(id: widget.id))),
    );
  }
}

class CheckBoxButton extends StatefulWidget {
  final bool isChecked;
  final String todoId;
  final Function(bool isChecked) onChanged;

  const CheckBoxButton({
    Key? key,
    required this.isChecked,
    required this.todoId,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CheckBoxButtonState createState() => _CheckBoxButtonState();
}

class _CheckBoxButtonState extends State<CheckBoxButton> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isChecked ? Icons.check_box : Icons.check_box_outline_blank,
        color: _isChecked ? Colors.green : Colors.grey,
      ),
      onPressed: () async {
        String? uid = await FirestoreManager().ReadUid(context);
        if (uid != null) {
          widget.onChanged(!_isChecked);
          setState(() {
            _isChecked = !_isChecked;
          });
          // Call the appropriate method based on the _isChecked state
          if (_isChecked) {
            ToDoManager().MarkToDoAsDone(widget.todoId, uid);
            ScoreManager().UpdateTodaysScore(25, uid);
          } else {
            ToDoManager().MarkToDoAsNotDone(widget.todoId, uid);
            ScoreManager().UpdateTodaysScore(-25, uid);
          }
        }
      },
    );
  }
}




