import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';
import '../Classes/Utils.dart';
import 'BasePage.dart';

class CreateAccountPage extends StatefulWidget{
  CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController = TextEditingController();
  bool isEmailValid = true;
  bool isPasswordValid = true;
  bool arePasswordsEqual = true;

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(body:
    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: screenWidth,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 60),
        child: Text("Willkommen!", style: GoogleFonts.montserrat(fontSize: 48), textAlign: TextAlign.center,),),
      Container(
          margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(enabledBorder: UnderlineInputBorder(),
                hintText: "Your Name", hintStyle: GoogleFonts.montserrat(color: Colors.grey)),
            keyboardType: TextInputType.text,)),
      Container(
        width: screenWidth,
        margin: EdgeInsets.fromLTRB(40, 0, 0, 0),
        child: Text(isEmailValid ? "Email" : "Email (!)", style: GoogleFonts.montserrat(fontSize: 14, color: isEmailValid ? Colors.black : Colors.red)),),
      Container(
          margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
          child: TextFormField(
            onChanged: (changes) {
              setState(() {
                isEmailValid = true;
              });
            },
            controller: emailController,
            decoration: InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: isEmailValid ? BorderSide(color: Colors.black) : BorderSide(color: Colors.red)),
                hintText: "max@mustermann.de", hintStyle: GoogleFonts.montserrat(color: Colors.grey)),
            keyboardType: TextInputType.text,)),
      Container(
        width: screenWidth,
        margin: EdgeInsets.fromLTRB(40, 20, 0, 0),
        child: Text(isPasswordValid ? "Passwort" : "Passwort (!)", style: GoogleFonts.montserrat(fontSize: 14, color: isPasswordValid ? Colors.black : Colors.red)),),
      Container(
          margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
          child: TextFormField(controller: passwordController,
              decoration: InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: isPasswordValid ? BorderSide(color: Colors.black) : BorderSide(color: Colors.red)),
                  hintText: "Sicheres Passwort eingeben", hintStyle: GoogleFonts.montserrat(color: Colors.grey)), obscureText: true)),
      Container(
        width: screenWidth,
        margin: EdgeInsets.fromLTRB(40, 20, 0, 0),
        child: Text(arePasswordsEqual ? "Passwort bestätigen" : "Passwort bestätigen (!)", style: GoogleFonts.montserrat(fontSize: 14, color: arePasswordsEqual ? Colors.black : Colors.red)),),
      Container(
          margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
          child: TextFormField(controller: passwordConfirmationController,
              decoration: InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: arePasswordsEqual ? BorderSide(color: Colors.black) : BorderSide(color: Colors.red)),
                  hintText: "Passwort erneut eingeben", hintStyle: GoogleFonts.montserrat(color: Colors.grey)), obscureText: true)),
      Container(margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),  width: screenWidth * 0.75,
          child: ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Utils().getColorFromHex("FF7A3D")), shape: MaterialStateProperty.all( RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)))),
              onPressed: () async {
                String name = nameController.text;
                String email = emailController.text;
                String password = passwordController.text;
                String passwordConfirmation = passwordConfirmationController.text;

                if(email.isEmpty || !Utils().isEmailOfValidFormat(email)) {
                  setState(() {
                    isEmailValid = false;
                  });
                  return;
                } else {
                  setState(() {
                    isEmailValid = true;
                  });
                }
                if(password.isEmpty) {
                  setState(() {
                    isPasswordValid = false;
                  });
                  return;
                }else {
                  setState(() {
                    isPasswordValid = true;
                  });
                }
                if(passwordConfirmation != password){
                  setState(() {
                    arePasswordsEqual = false;
                  });
                  return;
                } else {
                  setState(() {
                    arePasswordsEqual = true;
                  });
                }

                FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((user) {
                  FirestoreManager().SaveUserId(user, context);
                  FirestoreManager().CreateFirestoreUser(name, email, user.user?.uid);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                }).onError((FirebaseAuthException error, stackTrace) {
                  switch(error.code){
                    case "email-already-in-use":
                      setState(() {
                        isEmailValid = false;
                        debugPrint("ALREADY EXISTS");
                      });
                      break;
                    case "weak-password":
                      setState(() {
                        isPasswordValid = false;
                      });
                      break;
                  }
                }).catchError((error) {
                  debugPrint("Something" + error.toString());
                });
              },
              child: Text("Weiter", style: GoogleFonts.montserrat(fontSize: 14),))),
    ])
    );
  }
}
