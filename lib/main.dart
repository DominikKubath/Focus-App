import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData(scaffoldBackgroundColor: Color(secColor.value)),
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
    );
  }
}


