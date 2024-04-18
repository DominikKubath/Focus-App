import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studienarbeit_focus_app/UI%20Elements/MenuDrawer.dart';

import '../main.dart';

class StudyTimerPage extends StatefulWidget {
  @override
  _StudyTimerPageState createState() => _StudyTimerPageState();
}

class _StudyTimerPageState extends State<StudyTimerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Timer'),
      ),
      drawer: MenuDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeAdjustButton(Icons.arrow_upward, () {
                  _increaseDuration(Duration(hours: 1));
                }),
                _buildTimeAdjustButton(Icons.arrow_upward, () {
                  _increaseDuration(Duration(minutes: 5));
                }),
                _buildTimeAdjustButton(Icons.arrow_upward, () {
                  _increaseDuration(Duration(seconds: 30));
                }),
              ],
            ),
            SizedBox(height: 10),
            Consumer<TimerModel>(
              builder: (context, timerModel, _) => Text(
                _formatDuration(timerModel.duration),
                style: TextStyle(fontSize: 100),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeAdjustButton(Icons.arrow_downward, () {
                  _decreaseDuration(Duration(hours: 1));
                }),
                _buildTimeAdjustButton(Icons.arrow_downward, () {
                  _decreaseDuration(Duration(minutes: 5));
                }),
                _buildTimeAdjustButton(Icons.arrow_downward, () {
                  _decreaseDuration(Duration(seconds: 30));
                }),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Provider.of<TimerModel>(context, listen: false).startTimer();
                  },
                  child: Text('Start'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<TimerModel>(context, listen: false).pauseTimer();
                  },
                  child: Text('Stop'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<TimerModel>(context, listen: false).resetTimer();
              },
              child: Text('Reset Timer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAdjustButton(IconData icon, void Function() onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  void _increaseDuration(Duration increment) {
    Provider.of<TimerModel>(context, listen: false).increaseDuration(increment);
  }

  void _decreaseDuration(Duration decrement) {
    Provider.of<TimerModel>(context, listen: false).decreaseDuration(decrement);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${duration.inHours}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
