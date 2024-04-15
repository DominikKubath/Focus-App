import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Pages/AuthenticationPage.dart';
import '../FirestoreManager.dart';
import '../Pages/NotesPage.dart';
import '../Pages/ToDoListPage.dart';
import '../Pages/FlashCardsPage.dart';


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
              title: Text('Notes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotesPage()),
                );
              },
            ),
            ListTile(
              title: Text('Calendar'),
              onTap: () {
                // Handle item 2 click
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: Text("Flash Cards"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => FlashCardsPage())
                );
              },
            ),
            ListTile(
              title: Text("Abmelden"),
              onTap: (){
                FirestoreManager().LogOut(context);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthenticationPage(),
                    ),
                        (Route<dynamic> route) => false);
              }
            ),
          ],
        ),
      );
  }
}