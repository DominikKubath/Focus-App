import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Classes/TodoStatistic.dart';
import 'package:studienarbeit_focus_app/UI%20Elements/MenuDrawer.dart';

import '../Classes/Score.dart';
import '../Classes/UserInfo.dart';
import '../FirestoreManager.dart';
import '../ScoreManager.dart';
import '../ToDoManager.dart';
import '../UI Elements/ScoreStats.dart';
import '../UI Elements/TodoStats.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isMenuOpen = false;
  late Future<FSUser> userData;
  late Future<List<Score>?> scoreData;
  late Future<List<TodoStatistic>?> todoStats;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userData = _getUserData();
    scoreData = _getScoreData();
    todoStats = _getTodoStats();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: MenuDrawer(),
      backgroundColor: Colors.black87,
      body: Scrollbar(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Add padding for better spacing
          child: FutureBuilder(
            future: scoreData,
            builder: (context, scoreSnapshot) {
              if (scoreSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (scoreSnapshot.hasError) {
                return Center(child: Text('Error: ${scoreSnapshot.error}'));
              } else {
                List<Score>? scores = scoreSnapshot.data as List<Score>?;
                return FutureBuilder(
                  future: todoStats,
                  builder: (context, todoSnapshot) {
                    if (todoSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (todoSnapshot.hasError) {
                      return Center(child: Text('Error: ${todoSnapshot.error}'));
                    } else {
                      List<TodoStatistic>? todoStats =
                      todoSnapshot.data as List<TodoStatistic>?;
                      return ListView(
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Your Productivity Points The Past Week:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          scores != null
                              ? ScoreStatsWidget(scores: scores)
                              : Text('No scores available'),
                          SizedBox(height: 20),
                          Text(
                            'Your ToDo Statistics:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          // Add your TodoStatsWidget here
                          TodoStatsWidget(todoStats: todoStats ?? []),
                        ],
                      );
                    }
                  },
                );
              }
            },
          ),
        ),
      ),
    );

  }

  Widget _buildScoreChart(List<Score>? scores) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome back!',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Your Productivity Points The Past Week:',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          SizedBox(height: 20),
          scores != null
              ? ScoreStatsWidget(scores: scores)
              : Text('No scores available'),
          SizedBox(height: 20), // Add some space between the headline and TodoStatsWidget
          Text(
            'Your ToDo Statistics:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          FutureBuilder(
            future: todoStats,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<TodoStatistic>? todoStatsData = snapshot.data as List<TodoStatistic>?;
                return TodoStatsWidget(todoStats: todoStatsData ?? []);
              }
            },
          ),
        ],
      ),
    );
  }


  Future<FSUser> _getUserData() async {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      return FirestoreManager().GetUserData(userId);
    } else {
      return FSUser("Gast", "No Email");
    }
  }

  Future<List<Score>?> _getScoreData() async {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      return ScoreManager().GetScoresOfLastSevenDays(userId);
    }
    return null;
  }

  Future<List<TodoStatistic>?> _getTodoStats() async
  {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      return ToDoManager().GetTodoStatsOfLastSevenDays(userId);
    }
    return null;
  }

}
