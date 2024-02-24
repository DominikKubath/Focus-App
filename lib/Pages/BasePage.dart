import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/UI%20Elements/MenuDrawer.dart';

import '../Classes/UserInfo.dart';
import '../FirestoreManager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isMenuOpen = false;
  late Future<FSUser> userData;

  @override
  Widget build(BuildContext context) {
    userData = _getUserData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: MenuDrawer(),
      body: FutureBuilder<FSUser>(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            FSUser user = snapshot.data!;
            return Center(
              child: Text('Welcome ${user.name}'),
            );
          }
        },
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
}