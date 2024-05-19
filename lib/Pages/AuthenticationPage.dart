import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './CreateAccountPage.dart';
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
                width: screenWidth,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 60),
                child: Text("Study & Focus App",
                  style: GoogleFonts.montserrat(fontSize: 48),
                  textAlign: TextAlign.center,),),
              Container(
                width: screenWidth * 0.75,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text("Login"),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.greenAccent)),
                ),
              ),
              SizedBox(height: 40),
              Container(width: screenWidth * 0.75, child: Text("You dont have an account?"), alignment: Alignment.center,),
              SizedBox(height: 20),
              Container(
                  width: screenWidth * 0.75,
                  child:
                  ElevatedButton(onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreateAccountPage()));
                  }, child: Text("Sign Up"), style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.amberAccent)),))

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