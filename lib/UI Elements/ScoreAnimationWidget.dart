// ScoreAnimationWidget.dart
import 'package:flutter/material.dart';
import 'dart:async';

class ScoreAnimationWidget extends StatefulWidget {
  final int points;
  final bool isPositive;

  const ScoreAnimationWidget({
    Key? key,
    required this.points,
    required this.isPositive,
  }) : super(key: key);

  @override
  _ScoreAnimationWidgetState createState() => _ScoreAnimationWidgetState();
}

class _ScoreAnimationWidgetState extends State<ScoreAnimationWidget> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 1500), () {
      setState(() {
        _isVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: widget.isPositive ? Colors.green : Colors.red,
          ),
          Text(
            '${widget.isPositive ? '+' : '-'} ${widget.points}',
            style: TextStyle(
              fontSize: 16.0,
              color: widget.isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
