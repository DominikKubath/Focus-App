import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Classes/UserInfo.dart';

import 'Classes/FlashCard.dart';
import 'Classes/FlashCardDeck.dart';
import 'Classes/ToDoItem.dart';

class FirestoreManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference userCollection = _firestore.collection("user");

  static const String flashCardDecksCollectionName = "flashcards";
  static const String flashCardContentCollectionName = "content";

  Future<List<ToDoItem>> GetAllToDos(String uid) async
  {
    var userDocument = await userCollection.where("uid", isEqualTo: uid).get();
    return await userCollection.doc(userDocument.docs[0].id).collection("todos").get().then((value){
      List<ToDoItem> todos = [];
      value.docs.forEach((element) {
        debugPrint("GOT TODO " + element.data().toString());
        todos.add(ToDoItem.fromDoc(element));
      });
      return todos;
    });
  }

  void CreateNewToDo(ToDoItem newItem, String uid) async
  {
    newItem.isDone = false;

    var userDoc = await userCollection.where("uid", isEqualTo: uid).get();
    debugPrint("New ToDo item ID: ${userDoc.docs[0].id}");
    userCollection.doc(userDoc.docs[0].id).collection("todos").add(newItem.ToMap());
  }

  void UpdateToDoItem(ToDoItem item, String uid) async
  {
    var userDoc = await userCollection.where("uid", isEqualTo: uid).get();
    userCollection.doc(userDoc.docs[0].id).collection("todos").doc(item.id).update(item.ToMap());
  }

  void DeleteToDoItem(ToDoItem oldItem, String uid) async
  {
    var userDoc = await userCollection.where("uid", isEqualTo: uid).get();
    userCollection.doc(userDoc.docs[0].id).collection("todos").doc(oldItem.id).delete();
  }

  Future<List<FlashCardDeck>> GetAllFlashCardDecks(String uid) async
  {
    var userDocument = await userCollection.where("uid", isEqualTo: uid).get();
    return await userCollection.doc(userDocument.docs[0].id).collection(flashCardDecksCollectionName).get().then((value){
      List<FlashCardDeck> decks = [];
      value.docs.forEach((element) {
        debugPrint("GOT DECK " + element.data().toString());
        decks.add(FlashCardDeck.fromDoc(element));
      });
      return decks;
    });
  }

  Future<List<FlashCard>> GetAllFlashCardsOfDeck(String deckId, String uid) async
  {
    var user = await GetCurrentUser(uid);
    return await userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).collection(flashCardContentCollectionName).get().then((value){
      List<FlashCard> cards = [];
      value.docs.forEach((card) {
        cards.add(FlashCard.fromDoc(card));
      });
      return cards;
    });
  }

  void UpdateFlashCardField(String cardId, String fieldName, String newContent, String deckId, String userId) async
  {
    var user = await GetCurrentUser(userId);
    userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).collection(flashCardContentCollectionName).doc(cardId).update({fieldName : newContent});
  }

  void AddNewFlashCard(FlashCard card, String deckId, String uid) async
  {
    card.lastStudied = Timestamp.now();
    card.lastStatus = LastStatus.New;
    var user = await GetCurrentUser(uid);
    userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).collection(flashCardContentCollectionName).add(card.ToMap());
    UpdateDeckCardCount(deckId, uid);
  }

  void UpdateDeckCardCount(String deckId, String uid) async
  {
    var user = await GetCurrentUser(uid);
    var querySnapshot = await userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).collection(flashCardContentCollectionName).get();
    var cardCount = querySnapshot.docs.length;
    userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).update({FlashCardDeck.fieldCardCount : cardCount});
  }

  void RenameFlashCardDeck(String newName, FlashCardDeck deck, String uid) async
  {
    var user = await GetCurrentUser(uid);
    deck.name = newName;
    userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deck.id).update(deck.ToMap());
  }

  void DeleteFlashCardDeck(String deckId, String uid) async
  {
    var user = await GetCurrentUser(uid);
    userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).delete();
  }

  Future<List<FlashCardDeck>> CreateNewFlashCardDeck(FlashCardDeck newDeck, String uid) async {
    newDeck.cardCount = 0;

    var userDoc = await GetCurrentUser(uid);
    var newDeckRef = await userCollection.doc(userDoc.id).collection(flashCardDecksCollectionName).add(newDeck.ToMap());

    // Fetch the updated list of decks
    var updatedDecks = await GetAllFlashCardDecks(uid);

    return updatedDecks;
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

  Future<DocumentSnapshot> GetCurrentUser(String uid) async
  {
    var userSnapshot = await userCollection.where("uid", isEqualTo: uid).get();
    return userSnapshot.docs[0];
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