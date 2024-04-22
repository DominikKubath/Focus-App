import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/UI%20Elements/MenuDrawer.dart';

import '../Classes/Score.dart';
import '../Classes/UserInfo.dart';
import '../FirestoreManager.dart';
import '../ScoreManager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isMenuOpen = false;
  late Future<FSUser> userData;
  late Future<List<Score>?> scoreData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userData = _getUserData();
    scoreData = _getScoreData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: MenuDrawer(),
      backgroundColor: Colors.black87,
      body: Builder(
        builder: (context) {
          return FutureBuilder(
            future: scoreData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<Score>? scores = snapshot.data as List<Score>?;
                return _buildScoreChart(scores);
              }
            },
          );
        },
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
              ? Container(
            height: 300,
            padding: EdgeInsets.all(30),
            child: _buildLineChart(scores),
          )
              : Text('No scores available'),
        ],
      ),
    );
  }


  Widget _buildLineChart(List<Score> scores) {
    List<Color> gradientColors = [
      Colors.cyan,
      Colors.blue,
    ];

    List<Color> backgroundGradientColors = [
      Color(0xFF1E1E1E), // Dark grey
      Color(0xFF121212), // Darker grey
    ];


    return AspectRatio(
      aspectRatio: 5,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 28,
          top: 22,
          bottom: 12,
        ),
        child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: backgroundGradientColors,
          ),
        ),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: scores
                    .asMap()
                    .entries
                    .map((entry) => FlSpot(entry.key.toDouble(), entry.value.amount.toDouble()))
                    .toList(),
                isCurved: false,
                barWidth: 4,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: gradientColors
                        .map((color) => color.withOpacity(0.3))
                        .toList(),
                  ),
                ),
                gradient: LinearGradient(
                  colors: gradientColors,
                ),
              ),
            ],
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: bottomTitleWidgets,
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: Text(
                  'Productivity Points',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: leftTitleWidgets,
                  reservedSize: 42,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d)),
            ),
           ),
          ),
        ),
      ),
    );
  }

  Color gradientBackground(List<Color> gradientColors) {
    return Colors.transparent; // Use transparent color for background
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontSize: 16,
        color: Colors.white
    );
    Widget text;
    // Calculate the date for the last seven days based on the value
    final DateTime now = DateTime.now();
    final List<String> dates = [];
    for (int i = 7; i >= 0; i--) {
      final DateTime date = now.subtract(Duration(days: i));
      final String formattedDate = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
      dates.add(formattedDate);
    }

    // Use the value to get the corresponding date from the dates list
    final int index = value.toInt();
    final String dateText = index < dates.length ? dates[index] : '';

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(dateText, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontSize: 15,
        color: Colors.white
    );
    String text;
    if (value < 5) {
      if (value.toInt() % 5 == 0) {
        text = '${value.toInt()}';
      } else {
        return Container();
      }
    } else {
      if (value.toInt() % 30 == 0) {
        text = '${value.toInt()}';
      } else {
        return Container();
      }
    }

    return Text(text, style: style, textAlign: TextAlign.left);
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

}
