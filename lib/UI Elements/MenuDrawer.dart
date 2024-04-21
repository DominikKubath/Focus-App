import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studienarbeit_focus_app/Pages/AuthenticationPage.dart';
import 'package:studienarbeit_focus_app/Pages/StudyTimerPage.dart';
import '../FirestoreManager.dart';
import '../Pages/NotesPage.dart';
import '../Pages/ToDoListPage.dart';
import '../Pages/FlashCardsPage.dart';
import '../main.dart'; // Import your TimerModel class

class MenuDrawer extends StatelessWidget {
  final Color primaryColor = Color(0xFF009688);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: Provider.of<TimerModel>(context).isRunning
                    ? [Colors.red, Colors.white] // Red gradient when timer is running
                    : [Colors.green, Colors.white], // Green gradient when timer is not running
              ),
            ),
            child: DrawerHeader(
              padding: EdgeInsets.all(0),
              child: Container(
                color: Colors.transparent, // Set the background color of the DrawerHeader to transparent
                child: Consumer<TimerModel>(
                  builder: (context, timerModel, _) {
                    return Center(
                      child: Text(
                        timerModel.isRunning ? _formatDuration(timerModel.duration) : 'Study Timer Not Running',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('To Do Liste'),
            onTap: () {
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
            title: Text('Study Timer'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudyTimerPage()),
              );
            },
          ),
          ListTile(
            title: Text("Flash Cards"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FlashCardsPage()),
              );
            },
          ),
          ListTile(
            title: Text("Abmelden"),
            onTap: () {
              FirestoreManager().LogOut(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthenticationPage(),
                ),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${duration.inHours}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
