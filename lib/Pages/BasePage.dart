import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/UI%20Elements/MenuDrawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: MenuDrawer(),
      body: Container(
        child: Center(
          child: Text('Home Page'),
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