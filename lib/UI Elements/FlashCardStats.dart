import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Classes/FlashCardStatistic.dart';

import '../Classes/TodoStatistic.dart';

class FlashCardStatsWidget extends StatelessWidget {
  final List<FlashCardStatistic> flashCardStats;

  const FlashCardStatsWidget({Key? key, required this.flashCardStats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildLineChart(flashCardStats);
  }

  Widget _buildLineChart(List<FlashCardStatistic> flashCardStats) {
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
                lineChartBarData1_1,
                lineChartBarData1_2
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
                      fontSize: 14,
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
                    'Card Count -> Learned Cards (Blue) - Card Attempts (Yellow)',
                    style: TextStyle(
                      fontSize: 12,
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



  List<LineChartBarData> get lineBarsData1 => [
    lineChartBarData1_1,
    lineChartBarData1_2,
  ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
    isCurved: false,
    color: Colors.amber,
    barWidth: 8,
    isStrokeCapRound: true,
    dotData: const FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: flashCardStats
        .asMap()
        .entries
        .map((entry) =>
        FlSpot(entry.key.toDouble(), entry.value.attemptCount.toDouble()))
        .toList(),
  );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
    isCurved: false,
    color: Colors.blue,
    barWidth: 8,
    isStrokeCapRound: true,
    dotData: const FlDotData(show: false),
    belowBarData: BarAreaData(
      show: false,
    ),
    spots: flashCardStats
        .asMap()
        .entries
        .map((entry) =>
        FlSpot(entry.key.toDouble(), entry.value.learnedCards.toDouble()))
        .toList(),
  );

  FlTitlesData get titlesData1 => FlTitlesData(
    bottomTitles: AxisTitles(
      axisNameWidget: Text(
        'Date',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    leftTitles: AxisTitles(
      axisNameWidget: Text(
        'Card Count -> Learned Cards (Blue) - Card Attempts (Yellow)',
        style: TextStyle(
          fontSize: 10,
        ),
      ),
      sideTitles: SideTitles(
        showTitles: true,
        interval: 1,
        getTitlesWidget: leftTitleWidgets,
        reservedSize: 42,
      ),
    ),
  );

  LineChartData get sampleData1 => LineChartData(
    lineTouchData: lineTouchData1,
    gridData: gridData,
    titlesData: titlesData1,
    borderData: borderData,
    lineBarsData: lineBarsData1,
    minX: 0,
    maxX: 14,
    maxY: 4,
    minY: 0,
  );

  SideTitles get bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: bottomTitleWidgets,
  );

  FlGridData get gridData => const FlGridData(show: false);

  LineTouchData get lineTouchData1 => LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
    ),
  );

  FlBorderData get borderData => FlBorderData(
    show: true,
    border: Border(
      bottom: const BorderSide(color: Colors.transparent),
      left: const BorderSide(color: Colors.transparent),
      right: const BorderSide(color: Colors.transparent),
      top: const BorderSide(color: Colors.transparent),
    ),
  );


  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 16,
    );
    Widget text;
    // Calculate the date for the last seven days based on the value
    final DateTime now = DateTime.now();
    final List<String> dates = [];
    for (int i = 7; i >= 0; i--) {
      final DateTime date = now.subtract(Duration(days: i));
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
    if (value <= 10) {
      if (value.toInt() % 5 == 0) {
        text = '${value.toInt()}';
      } else {
        return Container();
      }
    } else {
      if (value.toInt() % 10 == 0) {
        text = '${value.toInt()}';
      } else {
        return Container();
      }
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

}




