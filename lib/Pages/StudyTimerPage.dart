import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studienarbeit_focus_app/UI%20Elements/MenuDrawer.dart';
import '../main.dart';

class StudyTimerPage extends StatefulWidget {
  @override
  _StudyTimerPageState createState() => _StudyTimerPageState();
}

class _StudyTimerPageState extends State<StudyTimerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Study Timer'),
      ),
      drawer: MenuDrawer(),
      body: Consumer<TimerModel>(
        builder: (context, timerModel, _) => AnimatedContainer(
          duration: Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: timerModel.isRunning
                  ? [Colors.white, Colors.red] // Red gradient when timer is running
                  : [Colors.white, Colors.green], // Green gradient when timer is not running
            ),
          ),
          child: Center(
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
                    style: TextStyle(
                        fontSize: 100,
                      color: Colors.white,
                    ),
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
                        Provider.of<TimerModel>(context, listen: false).setOnTimerFinishedCallback(() => onTimerFinished(context));
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

  void onTimerFinished(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Timer ran out!'),
      ),
    );
  }
}
