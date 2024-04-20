import 'package:flutter/material.dart';
import '../FirestoreManager.dart';
import '../Pages/ToDoItemPage.dart';
import '../Classes/ToDoItem.dart';
import '../Constants/ColorPalette.dart';
import '../Classes/Utils.dart';
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

class CheckBoxButton extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool>? onChanged;
  final String todoId;

  const CheckBoxButton({
    Key? key,
    required this.isChecked,
    this.onChanged,
    required this.todoId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isChecked ? Icons.check_box : Icons.check_box_outline_blank,
        color: isChecked ? Colors.green : Colors.grey,
      ),
      onPressed: () async {
        String? uid = await FirestoreManager().ReadUid(context);
        if (onChanged != null) {
          onChanged!(!isChecked);
          // Call the appropriate method based on the isChecked state
          if(uid != null)
          {
            if (isChecked) {
              ToDoManager().MarkToDoAsNotDone(todoId, uid);
            } else {
              ToDoManager().MarkToDoAsDone(todoId, uid);
            }
          }
        }
      },
    );
  }
}



