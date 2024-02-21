import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class FSUser {
  // "late" allows the variables to be "null" at first and
  // it doesnt require it being initialised
  late String id;
  late String name;
  late String email;

  // just to not have to write the "column names" out everytime a change is made
  // makes the chance of typos smaller
  static const String fieldName = "name";
  static const String fieldId = "uid";
  static const String fieldEmail = "email";

  //Constructor
  FSUser(this.name, this.email, {this.id = ""});

  //This Method returns the information of a user document
  //as a User object
  FSUser.fromDoc(DocumentSnapshot document)
  {
    id = document[FSUser.fieldId];
    name = document[FSUser.fieldName];
    email = document[FSUser.fieldEmail];
  }

  //This Method converts the data into a format that is used in firestore
  // => need to convert data into a map to insert it into firestore - this automates that for this class
  Map<String, dynamic> ToMap()
  {
    return{
      FSUser.fieldId : id,
      FSUser.fieldName : name,
      FSUser.fieldEmail : email
    };
  }
}
