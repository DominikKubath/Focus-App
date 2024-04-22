import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studienarbeit_focus_app/Pages/AuthenticationPage.dart';
import 'package:studienarbeit_focus_app/Pages/BasePage.dart';
import 'package:studienarbeit_focus_app/Pages/StudyTimerPage.dart';
import '../Classes/Score.dart';
import '../FirestoreManager.dart';
import '../Pages/NotesPage.dart';
import '../Pages/ToDoListPage.dart';
import '../Pages/FlashCardsPage.dart';
import '../ScoreManager.dart';
import '../main.dart'; // Import your TimerModel class

class MenuDrawer extends StatelessWidget {
  final Color primaryColor = Color(0xFF009688);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<int>(
        future: fetchTodaysScore(context), // Call method to fetch today's score
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display loading indicator while score is being fetched
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Display error message if fetching score fails
            return Text('Error fetching score: ${snapshot.error}');
          } else {
            // Display Drawer with fetched score
            return buildDrawerWithScore(context, snapshot.data);
          }
        },
      ),
    );
  }

  Future<int> fetchTodaysScore(BuildContext context) async {
    var userId = await FirestoreManager().ReadUid(context);

    if(userId != null)
    {
      Score? todaysScore = await ScoreManager().GetTodaysScore(ScoreManager.scoreCollectionName, userId);
      if(todaysScore != null)
      {
        return todaysScore.amount;
      }
    }
    return 0; // Replace with the actual score fetched from the database
  }

  Widget buildDrawerWithScore(BuildContext context, int? todaysScore) {
    return ListView(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<TimerModel>(
                      builder: (context, timerModel, _) {
                        return Text(
                          timerModel.isRunning ? _formatDuration(timerModel.duration) : 'Study Timer Not Running',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 32,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Today\'s Productivity Score: ${todaysScore ?? 0}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ListTile(
          title: Text('Home / Statistics'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        ListTile(
          title: Text('To-Do List'),
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
          title: Text("Log Out"),
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
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${duration.inHours}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
