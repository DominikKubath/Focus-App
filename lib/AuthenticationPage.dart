import 'package:flutter/material.dart';
import 'AuthButton.dart';
import 'UserInfo.dart';

class AuthenticationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthButton(),
            SizedBox(height: 20),
            UserInfo(),
          ],
        ),
      ),
    );
  }
}