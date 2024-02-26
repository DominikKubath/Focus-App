import 'package:flutter/material.dart';
import '../Pages/ToDoItemPage.dart';
import '../Classes/ToDoItem.dart';
import '../Constants/ColorPalette.dart';
import '../Classes/Utils.dart';
import 'EditToDoDialog.dart';
import '../UI Elements/DeleteConfirmationDialog.dart';

class ToDoItemWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      contentPadding: const EdgeInsets.only(top: 5, left: 70, right: 70, bottom: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      tileColor: ColorPalette.bgColor,
      leading: _buildLeading(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: ColorPalette.funcBlue),
            onPressed: () => EditToDoDialog.showEditDialog(context, title, description, id, priority),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: ColorPalette.funcBlue),
            onPressed: () => DeleteConfirmationDialog.DeleteToDoItem(context, id),
          ),
        ],
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ToDoItemPage(id: id))),
    );
  }

  Widget _buildLeading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.check_box_outline_blank, color: ColorPalette.Green),
        const SizedBox(width: 10),
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Utils.getPriorityColor(priority),
          ),
        ),
      ],
    );
  }
}




