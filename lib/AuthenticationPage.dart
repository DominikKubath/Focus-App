import 'package:flutter/material.dart';

import 'CreateAccountPage.dart';
import 'LoginPage.dart';

class AuthenticationPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.75,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text("Anmelden"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white)),
                ),
              ),
              Container(width: screenWidth * 0.75, child: Text("Noch kein Konto?")),
              Container(
                  width: screenWidth * 0.75,
                  child:
                  ElevatedButton(onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreateAccountPage()));
                  }, child: Text("Registrieren")))
            ],
          ),
        ));
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Balls")
          ],
        ),
      ),
    );
  }*/
}