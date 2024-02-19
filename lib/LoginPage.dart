import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Utils.dart';
import 'BasePage.dart';

class LoginPage extends StatefulWidget{
  LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
    bool isInvalid = false;

    @override
    Widget build(BuildContext context) {
      TextEditingController emailController = TextEditingController();
      TextEditingController passwordController = TextEditingController();

      double screenWidth = MediaQuery
          .of(context)
          .size
          .width;

      return Scaffold(
          body: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 60),
                child: Text("Willkommen zurück!",
                  style: GoogleFonts.montserrat(fontSize: 48),
                  textAlign: TextAlign.center,),),
              Container(
                width: screenWidth,
                margin: EdgeInsets.fromLTRB(40, 0, 0, 0),
                child: Text(
                    "E-Mail", style: GoogleFonts.montserrat(fontSize: 14)),),
              Container(
                  margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: TextFormField(controller: emailController,
                    decoration: InputDecoration(hintText: "max@mustermann.de",
                        hintStyle: GoogleFonts.montserrat(color: Colors.grey)),
                    keyboardType: TextInputType.text,)),
              Container(
                width: screenWidth,
                margin: EdgeInsets.fromLTRB(40, 20, 0, 0),
                child: Text(
                    "Passwort", style: GoogleFonts.montserrat(fontSize: 14)),),
              Container(
                  margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: TextFormField(controller: passwordController,
                      decoration: InputDecoration(hintText: "Dein Passwort",
                          hintStyle: GoogleFonts.montserrat(
                              color: Colors.grey)), obscureText: true)),
              if(isInvalid) Container(
                width: screenWidth,
                margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Text("Login fehlgeschlagen",
                    style: GoogleFonts.montserrat(
                        fontSize: 14, color: Colors.red)),),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  width: screenWidth * 0.75,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Utils().getColorFromHex("FF7A3D")),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)))),
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text)
                              .then((value) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                                    (Route<dynamic> route) => false);
                          });
                        } catch (e) {
                          debugPrint("Error while signing in: " + e.toString());
                          setState(() {
                            isInvalid = true;
                          });
                        }
                        debugPrint(emailController.text + " " +
                            passwordController.text);
                      },
                      child: Text("Anmelden"))),
            ],
          )
      );
    }
}