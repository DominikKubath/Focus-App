import 'package:flutter/material.dart';
import 'ToDoListPage.dart';


class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menu Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('To Do Liste'),
              onTap: () {
                // Handle item 1 click
                //Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ToDoListPage()),
                );
              },
            ),
            ListTile(
              title: Text('Kalender'),
              onTap: () {
                // Handle item 2 click
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      );
  }
}