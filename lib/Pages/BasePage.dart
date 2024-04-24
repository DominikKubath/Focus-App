import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Classes/FlashCardStatistic.dart';
import 'package:studienarbeit_focus_app/Classes/TodoStatistic.dart';
import 'package:studienarbeit_focus_app/UI%20Elements/FlashCardStats.dart';
import 'package:studienarbeit_focus_app/UI%20Elements/MenuDrawer.dart';

import '../Classes/Score.dart';
import '../Classes/UserInfo.dart';
import '../FirestoreManager.dart';
import '../ScoreManager.dart';
import '../ToDoManager.dart';
import '../UI Elements/ScoreStats.dart';
import '../UI Elements/TimerStats.dart';
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
  late Future<List<FlashCardStatistic>?> cardStats;
  late Future<List<Score>?> timerStats;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userData = _getUserData();
    scoreData = _getScoreData();
    todoStats = _getTodoStats();
    cardStats = _getFlashCardStats();
    timerStats = _getTimerStats();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: MenuDrawer(),
      body: Scrollbar(
        controller: _scrollController,
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
                      return FutureBuilder(
                        future: cardStats,
                        builder: (context, cardSnapshot) {
                          if (cardSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator());
                          } else if (cardSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${cardSnapshot.error}'));
                          } else {
                            List<FlashCardStatistic>? cardStats =
                            cardSnapshot.data as List<FlashCardStatistic>?;
                            return FutureBuilder(
                              future: timerStats,
                              builder: (context, timerSnapshot) {
                                if (timerSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (timerSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error: ${timerSnapshot.error}'));
                                } else {
                                  List<Score>? timerStats =
                                  timerSnapshot.data as List<Score>?;
                                  return ListView(
                                    children: [
                                      Text(
                                        'Welcome back!',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 50),
                                      Text(
                                        'Your Productivity Points The Past Week:',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 50),
                                      scores != null
                                          ? ScoreStatsWidget(scores: scores)
                                          : Text('No scores available'),
                                      SizedBox(height: 50),
                                      Text(
                                        'Your ToDo Statistics:',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 50),
                                      // Add your TodoStatsWidget here
                                      TodoStatsWidget(todoStats: todoStats ?? []),
                                      SizedBox(height: 50),
                                      Text(
                                        'Your FlashCard Statistics:',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 50),
                                      // Add your FlashCardStatsWidget here
                                      FlashCardStatsWidget(
                                          flashCardStats: cardStats ?? []),
                                      SizedBox(height: 50),
                                      Text(
                                        'Your Timer Intervals:',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      // Add your TimerStatsWidget here
                                      TimerStatsWidget(timeStats: timerStats ?? []),
                                    ],
                                  );
                                }
                              },
                            );
                          }
                        },
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
      return ScoreManager().GetScoresOfLastSevenDays(ScoreManager.scoreCollectionName, userId);
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

  Future<List<FlashCardStatistic>?> _getFlashCardStats() async
  {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      return FirestoreManager().GetCardsStatsOfLastSevenDays(userId);
    }
    return null;
  }

  Future<List<Score>?> _getTimerStats() async
  {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      return ScoreManager().GetScoresOfLastSevenDays(ScoreManager.timerStatsCollectionName, userId);
    }
    return null;
  }

}
