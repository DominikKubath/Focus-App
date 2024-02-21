import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:js';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/UserInfo.dart';

class FirestoreManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference userCollection = _firestore.collection("user");

  void CreateFirestoreUser(name, email, id) async
  {
    FSUser user = FSUser(name, email);
    user.id = id;
    userCollection.add(user.ToMap());
  }

  void SaveUserId(UserCredential userCredentials, BuildContext context) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = userCredentials.user?.uid;
    id ??= ""; //If id == null => ""
    if(kIsWeb){
      html.document.cookie = 'uid=$id';
    }
    else if (Theme.of(context).platform == TargetPlatform.android) {
      // Android platform: Use shared_preferences to save user ID
      await prefs.setString('uid', id);
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      // iOS platform: Handle accordingly
      // You may use a different storage solution for iOS if needed.
    }
  }
}