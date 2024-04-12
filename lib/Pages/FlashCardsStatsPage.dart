import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../Classes/Attempt.dart';
import '../Classes/FlashCardDeck.dart';

class FlashCardStatPage extends StatefulWidget {
  final FlashCardDeck deck;

  const FlashCardStatPage({Key? key, required this.deck}) : super(key: key);

  @override
  _FlashCardStatPageState createState() => _FlashCardStatPageState();
}

class _FlashCardStatPageState extends State<FlashCardStatPage> {
  late List<Attempt> attempts;
  late int attemptsToday;

  @override
  void initState() {
    super.initState();
    loadAttempts();
  }

  Future<void> loadAttempts() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final todayStartTimestamp = Timestamp.fromDate(startOfDay);
    final todayEndTimestamp = Timestamp.fromDate(endOfDay);

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('attempts')
        .where('attemptStart', isGreaterThanOrEqualTo: todayStartTimestamp)
        .where('attemptStart', isLessThan: todayEndTimestamp)
        .get();

    setState(() {
      attempts = querySnapshot.docs.map((doc) => Attempt.fromDoc(doc)).toList();
      attemptsToday = attempts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlashCard Statistics'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Attempts Today: $attemptsToday'),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [FlSpot(0, attemptsToday.toDouble())],
                        isCurved: true,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
