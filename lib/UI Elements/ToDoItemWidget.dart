import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../Pages/ToDoItemPage.dart';


class ToDoItemWidget extends StatelessWidget {
  String title;
  String description;
  String id;

  ToDoItemWidget({required this.title, required this.id, required this.description});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      contentPadding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      tileColor: Color(secColor.value),
      leading: Icon(Icons.check_box, color: Color(tdGreen.value)),
      trailing: Icon(Icons.more_vert),
      onTap: () {
        // Handle the tap, navigate to a new screen, etc.
        // You can use deck.id to pass the selected deck ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ToDoItemPage(id: id),
          ),
        );
      },
    );
  }
}
