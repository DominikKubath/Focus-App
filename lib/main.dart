import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';
import 'package:studienarbeit_focus_app/Pages/ToDoListPage.dart';
import 'firebase_options.dart';

import 'Pages/BasePage.dart';
import 'Pages/AuthenticationPage.dart';
import 'Classes/UserInfo.dart';
import 'LoadingScreen.dart';
import 'constants/ColorPalette.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Color primaryColor = Color(0xFF009688);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimerModel(),
      child: MaterialApp(
        theme: ThemeData(
            primaryColor: primaryColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingScreen();
            } else {
              if (snapshot.hasData) {
                return HomePage();
              } else {
                return AuthenticationPage();
              }
            }
          },
        ),
      ),
    );
  }
}

class TimerModel extends ChangeNotifier {
  Duration _duration = Duration(minutes: 25);
  bool _isRunning = false;
  late Timer _timer;

  Duration get duration => _duration;
  bool get isRunning => _isRunning;

  void increaseDuration(Duration increment) {
    _duration += increment;
    notifyListeners();
  }

  void decreaseDuration(Duration decrement) {
    if (_duration > decrement) {
      _duration -= decrement;
      notifyListeners();
    }
  }

  void startTimer() {
    if (!_isRunning) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_duration.inSeconds > 0) {
          _duration = Duration(seconds: _duration.inSeconds - 1);
          notifyListeners();
        } else {
          _isRunning = false;
          _timer.cancel();
          notifyListeners();
        }
      });
      _isRunning = true;
      notifyListeners();
    }
  }

  void pauseTimer() {
    if (_isRunning) {
      _timer.cancel();
      _isRunning = false;
      notifyListeners();
    }
  }

  void resetTimer() {
    _timer.cancel();
    _duration = Duration(minutes: 25);
    _isRunning = false;
    notifyListeners();
  }
}



