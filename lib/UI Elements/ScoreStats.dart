import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../Classes/Score.dart';

class ScoreStatsWidget extends StatelessWidget {
  final List<Score> scores;

  const ScoreStatsWidget({Key? key, required this.scores}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildLineChart(scores);
  }

  Widget _buildLineChart(List<Score> scores) {
    List<Color> gradientColors = [
      Colors.cyan,
      Colors.blue,
    ];

    List<Color> backgroundGradientColors = [
      Color(0x83D3D3D3), // Dark grey
      Color(0x83CBCBCB), // Darker grey
    ];

    return AspectRatio(
      aspectRatio: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
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
                      .map((entry) =>
                      FlSpot(entry.key.toDouble(), entry.value.amount.toDouble()))
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
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    ),
                  ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitlesWidget: bottomTitleWidgets,
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Productivity Points',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: leftTitleWidgets,
                    reservedSize: 50,
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

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 16,
    );
    Widget text;
    // Calculate the date for the last seven days based on the value
    final DateTime now = DateTime.now();
    final List<String> dates = [];
    for (int i = 7; i >= 0; i--) {
      final DateTime date = now.subtract(Duration(days: i-1));
      final String formattedDate =
          '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
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
}
