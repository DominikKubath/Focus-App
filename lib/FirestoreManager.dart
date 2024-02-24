import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Classes/UserInfo.dart';

import 'Classes/FlashCardDeck.dart';

class FirestoreManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference userCollection = _firestore.collection("user");


  Future<List<FlashCardDeck>> GetAllFlashCardDecks(String uid) async
  {
    var userDocument = await userCollection.where("uid", isEqualTo: uid).get();
    return await userCollection.doc(userDocument.docs[0].id).collection("flashcards").get().then((value){
      List<FlashCardDeck> decks = [];
      value.docs.forEach((element) {
        debugPrint("GOT DECK " + element.data().toString());
        decks.add(FlashCardDeck.fromDoc(element));
      });
      return decks;
    });
  }



  void CreateFirestoreUser(name, email, id) async
  {
    FSUser user = FSUser(name, email);
    user.id = id;
    userCollection.add(user.ToMap());
  }

  Future<FSUser> GetUserData(String uid) async
  {
    return await userCollection.where("uid", isEqualTo: uid).get().then((value){
      return FSUser.fromDoc(value.docs[0]);
    });
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

  void LogOut(BuildContext context) async
  {
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Android platform: Use shared_preferences to clear user ID
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('uid');
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      // iOS platform: Handle accordingly
      // You may use a different storage solution for iOS if needed.
    } else if (kIsWeb) {
      html.window.document.cookie = 'uid=; expires=Thu, 01 Jan 1970 00:00:00 GMT';
    }
  }

  Future<String?> ReadUid(BuildContext context) async
  {
    if (Theme.of(context).platform == TargetPlatform.android)
    {
      // Android platform: Use shared_preferences to read user ID
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      // iOS platform: Handle accordingly
      // You may use a different storage solution for iOS if needed.
      return null;
    } else if (kIsWeb) {
      // Web platform: Use dart:html to read the user ID cookie
      final cookie = html.window.document.cookie;
      final userIdCookie = cookie!.split(';').firstWhere(
            (element) => element.contains('uid'),
        orElse: () => '',
      );
      return userIdCookie.split('=').last.trim();
    }
    return null;
  }
}