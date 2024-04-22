import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Classes/UserInfo.dart';

import 'Classes/Attempt.dart';
import 'Classes/FlashCard.dart';
import 'Classes/FlashCardDeck.dart';
import 'Classes/FlashCardStatistic.dart';
import 'Classes/ToDoItem.dart';
import 'Classes/Utils.dart';

class FirestoreManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference userCollection = _firestore.collection("user");

  static const String flashCardDecksCollectionName = "flashcards";
  static const String flashCardContentCollectionName = "content";
  static const String flashCardAttemptCollectionName = "attempts";

  static const String flashCardsStatsCollectionName = "allFlashcardsStats";
  static const String deckStatsCollectionName = "stats";

  void UpdateFlashCardStats(int count, String fieldName, String uid) async
  {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        FlashCardStatistic? todayScore = await GetTodaysFlashCardsStats(uid);
        if (todayScore == null) {
          CreateTodaysCardStatsIfNotExisting(uid, fieldName, count);
        } else {
          int updatedAmount = 0;
          if(fieldName == "attemptsCount")
          {
            updatedAmount = todayScore.attemptCount + count;
          }
          else
          {
            updatedAmount = todayScore.learnedCards + count;
          }
          await userCollection
              .doc(userDoc.id)
              .collection(flashCardsStatsCollectionName)
              .doc(todayScore.docId)
              .update({fieldName: updatedAmount});
        }
      } catch (e) {
        print("Error updating today's score: $e");
      }
    }
  }

  Future<FlashCardStatistic?> GetTodaysFlashCardsStats(String uid) async
  {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if(userDoc != null)
    {
      try {
        DateTime today = DateTime.now();
        DateTime startOfToday = DateTime(today.year, today.month, today.day);
        QuerySnapshot querySnapshot = await userCollection
            .doc(userDoc.id)
            .collection(flashCardsStatsCollectionName)
            .where(FlashCardStatistic.dateFieldName, isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
            .where(FlashCardStatistic.dateFieldName, isLessThan: Timestamp.fromDate(startOfToday.add(Duration(days: 1))))
            .limit(1)
            .get();

        debugPrint(FlashCardStatistic.fromDoc(querySnapshot.docs.first).docId);
        if (querySnapshot.docs.isNotEmpty) {
          return FlashCardStatistic.fromDoc(querySnapshot.docs.first);
        } else {
          return null;
        }
      } catch (e) {
        print("Error fetching today's score: $e");
        return null;
      }
    }
  }

  Future<List<FlashCardStatistic>?> GetCardsStatsOfLastSevenDays(String uid) async
  {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        DateTime sevenDaysAgo = today.subtract(Duration(days: 7));

        QuerySnapshot querySnapshot = await userCollection
            .doc(userDoc.id)
            .collection(flashCardsStatsCollectionName)
            .where(FlashCardStatistic.dateFieldName, isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
            .where(FlashCardStatistic.dateFieldName, isLessThan: Timestamp.fromDate(today))
            .orderBy(FlashCardStatistic.dateFieldName, descending: true)
            .get();

        List<FlashCardStatistic> cardStats = querySnapshot.docs.map((doc) => FlashCardStatistic.fromDoc(doc)).toList();

        // Check for missing dates and add dummy scores
        for (int i = 0; i <= 7; i++) {
          DateTime dateToCheck = today.subtract(Duration(days: i));
          bool dateExists = cardStats.any((score) => score.date.toDate().year == dateToCheck.year && score.date.toDate().month == dateToCheck.month && score.date.toDate().day == dateToCheck.day);
          if (!dateExists) {
            // Create a dummy score with amount 0 for missing date
            FlashCardStatistic dummyStat = FlashCardStatistic.empty();
            dummyStat.docId = '';
            dummyStat.date = Timestamp.fromDate(dateToCheck);
            dummyStat.attemptCount = 0;
            dummyStat.learnedCards = 0;
            cardStats.add(dummyStat);
          }
        }

        // Sort the list by date
        cardStats.sort((a, b) => a.date.compareTo(b.date));
        return cardStats;
      } catch (e) {
        print("Error fetching scores of last seven days: $e");
        return null;
      }
    }
  }

  void CreateTodaysCardStatsIfNotExisting(String uid, String fieldName, int initialAmount) async {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        DateTime startOfToday = DateTime(today.year, today.month, today.day);
        FlashCardStatistic? todayScore = await GetTodaysFlashCardsStats(uid);
        if (todayScore == null) {
          if(fieldName == "attemptsCount")
          {
            await userCollection.doc(userDoc.id).collection(flashCardsStatsCollectionName).add({
              fieldName: initialAmount,
              "learnedCards" : 0,
              FlashCardStatistic.dateFieldName: Timestamp.fromDate(startOfToday)
            });
          }
          else
          {
            await userCollection.doc(userDoc.id).collection(flashCardsStatsCollectionName).add({
              fieldName: initialAmount,
              "attemptsCount" : 0,
              FlashCardStatistic.dateFieldName: Timestamp.fromDate(startOfToday)
            });
          }
        }
      } catch (e) {
        print("Error creating today's score: $e");
      }
    }
  }



  void UpdateDeckStats(int count, String fieldName, String deckId, String uid) async
  {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        FlashCardStatistic? todayScore = await GetTodaysDeckStats(deckId, uid);
        if (todayScore == null) {
          CreateTodaysDeckStatsIfNotExisting(uid, deckId, fieldName, count);
        } else {
          int updatedAmount = 0;
          if(fieldName == "attemptsCount")
          {
            updatedAmount = todayScore.attemptCount + count;
          }
          else
          {
            updatedAmount = todayScore.learnedCards + count;
          }
          await userCollection
              .doc(userDoc.id)
              .collection(flashCardsStatsCollectionName)
              .doc(todayScore.docId)
              .update({fieldName: updatedAmount});
        }
      } catch (e) {
        print("Error updating today's score: $e");
      }
    }
  }

  Future<FlashCardStatistic?> GetTodaysDeckStats(String deckId, String uid) async
  {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if(userDoc != null)
    {
      try {
        DateTime today = DateTime.now();
        DateTime startOfToday = DateTime(today.year, today.month, today.day);
        QuerySnapshot querySnapshot = await userCollection
            .doc(userDoc.id)
            .collection(flashCardDecksCollectionName)
            .doc(deckId)
            .collection(deckStatsCollectionName)
            .where(FlashCardStatistic.dateFieldName, isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
            .where(FlashCardStatistic.dateFieldName, isLessThan: Timestamp.fromDate(startOfToday.add(Duration(days: 1))))
            .limit(1)
            .get();

        debugPrint(FlashCardStatistic.fromDoc(querySnapshot.docs.first).docId);
        if (querySnapshot.docs.isNotEmpty) {
          return FlashCardStatistic.fromDoc(querySnapshot.docs.first);
        } else {
          return null;
        }
      } catch (e) {
        print("Error fetching today's score: $e");
        return null;
      }
    }
  }

  Future<List<FlashCardStatistic>?> GetDeckStatsOfLastSevenDays(String deckId, String uid) async
  {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        DateTime sevenDaysAgo = today.subtract(Duration(days: 7));

        QuerySnapshot querySnapshot = await userCollection
            .doc(userDoc.id)
            .collection(flashCardDecksCollectionName)
            .doc(deckId)
            .collection(deckStatsCollectionName)
            .where(FlashCardStatistic.dateFieldName, isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
            .where(FlashCardStatistic.dateFieldName, isLessThan: Timestamp.fromDate(today))
            .orderBy(FlashCardStatistic.dateFieldName, descending: true)
            .get();

        List<FlashCardStatistic> cardStats = querySnapshot.docs.map((doc) => FlashCardStatistic.fromDoc(doc)).toList();

        // Check for missing dates and add dummy scores
        for (int i = 0; i <= 7; i++) {
          DateTime dateToCheck = today.subtract(Duration(days: i));
          bool dateExists = cardStats.any((score) => score.date.toDate().year == dateToCheck.year && score.date.toDate().month == dateToCheck.month && score.date.toDate().day == dateToCheck.day);
          if (!dateExists) {
            // Create a dummy score with amount 0 for missing date
            FlashCardStatistic dummyStat = FlashCardStatistic.empty();
            dummyStat.docId = '';
            dummyStat.date = Timestamp.fromDate(dateToCheck);
            dummyStat.attemptCount = 0;
            dummyStat.learnedCards = 0;
            cardStats.add(dummyStat);
          }
        }

        // Sort the list by date
        cardStats.sort((a, b) => a.date.compareTo(b.date));
        return cardStats;
      } catch (e) {
        print("Error fetching scores of last seven days: $e");
        return null;
      }
    }
  }

  void CreateTodaysDeckStatsIfNotExisting(String uid, String deckId, String fieldName, int initialAmount) async {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        DateTime startOfToday = DateTime(today.year, today.month, today.day);
        FlashCardStatistic? todayScore = await GetTodaysDeckStats(deckId, uid);
        if (todayScore == null) {
          if(fieldName == "attemptsCount")
          {
            await userCollection.doc(userDoc.id).collection(flashCardDecksCollectionName).doc(deckId).collection(deckStatsCollectionName).add({
              fieldName: initialAmount,
              "learnedCards" : 0,
              FlashCardStatistic.dateFieldName: Timestamp.fromDate(startOfToday)
            });
          }
          else
          {
            await userCollection.doc(userDoc.id).collection(flashCardDecksCollectionName).doc(deckId).collection(deckStatsCollectionName).add({
              fieldName: initialAmount,
              "attemptsCount" : 0,
              FlashCardStatistic.dateFieldName: Timestamp.fromDate(startOfToday)
            });
          }
        }
      } catch (e) {
        print("Error creating today's score: $e");
      }
    }
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

  Future<List<FlashCard>> GetAllFlashCardsOfDeck(String deckId, String uid, String filter) async {
    var user = await GetCurrentUser(uid);
    var cardsSnapshot = await userCollection
        .doc(user.id)
        .collection(flashCardDecksCollectionName)
        .doc(deckId)
        .collection(flashCardContentCollectionName)
        .get();

    List<FlashCard> cards = [];
    for (var card in cardsSnapshot.docs) {
      var retrievedCard = FlashCard.fromDoc(card);
      retrievedCard.attempts = await GetAllAttemptsOfFlashCard(deckId, retrievedCard.docId, uid);
      cards.add(retrievedCard);
    }

    filter = filter.toUpperCase();
    var sortedCards;
    switch(filter)
    {
      case "DEFAULT":
        sortedCards = Utils().DefaultSortFlashCards(cards);
        break;
      case "OLDEST":
        sortedCards = Utils().CardSortOptionOldest(cards);
        break;
      case "NEW":
        sortedCards = Utils().CardSortOptionNew(cards);
        break;
      case "HARDEST":
        sortedCards = Utils().CardSortOptionHardest(cards);
        break;
    }
    return sortedCards ?? [];
  }

  void UpdateFlashCardField(String cardId, String fieldName, String newContent, String deckId, String userId) async
  {
    var user = await GetCurrentUser(userId);
    userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).collection(flashCardContentCollectionName).doc(cardId).update({fieldName : newContent});
  }

  void UpdateFlashCardStatusAndLastStudied(FlashCard card, String deckId, String userId) async
  {
    var user = await GetCurrentUser(userId);
    Map<String, dynamic> updatedDoc = {
      FlashCard.fieldLastStudied : card.lastStudied,
      FlashCard.fieldLastStatus : card.lastStatus.name.toString()
    };
    userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).collection(flashCardContentCollectionName).doc(card.docId).update(updatedDoc);
  }

  void AddFlashCardAttempt(Attempt attempt, String deckId, String flashCardId, String uid) async
  {
    var user = await GetCurrentUser(uid);
    userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId)
        .collection(flashCardContentCollectionName).doc(flashCardId).collection(flashCardAttemptCollectionName).add(attempt.ToMap());
    if(attempt.status == LastStatus.Easy)
    {
      UpdateFlashCardStats(1, FlashCardStatistic.learnedCardsFieldName, uid);
      UpdateDeckStats(1, FlashCardStatistic.learnedCardsFieldName, deckId, uid);
    }
    else
    {
      UpdateFlashCardStats(1, FlashCardStatistic.attemptCountFieldName, uid);
      UpdateDeckStats(1, FlashCardStatistic.attemptCountFieldName, deckId, uid);
    }
  }

  Future<List<Attempt>> GetAllAttemptsOfFlashCard(String deckId, String flashCardDocId, String uid) async
  {
    var user = await GetCurrentUser(uid);
    return await userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).collection(flashCardContentCollectionName).doc(flashCardDocId).collection(flashCardAttemptCollectionName).get()
        .then((value) {
      List<Attempt> attempts = [];
      value.docs.forEach((attempt) {
        attempts.add(Attempt.fromDoc(attempt));
      });
      return attempts;
    });
  }

  Future<List<Attempt>> GetAllAttemptsOfDeck(String deckId, String uid) async
  {
    /*var user = await GetCurrentUser(uid);
    var deckRef = userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId);

    var flashcardsQuerySnapshot = await deckRef.collection(flashCardContentCollectionName).get();
    for (var docSnapshot in flashcardsQuerySnapshot.docs) {
      await docSnapshot.reference.delete();
    }*/
    return [];
  }

  Future<DocumentReference<Map<String, dynamic>>> AddNewFlashCard(FlashCard card, String deckId, String uid) async
  {
    card.lastStudied = Timestamp.now();
    card.lastStatus = LastStatus.New;
    var user = await GetCurrentUser(uid);
    var result = await userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).collection(flashCardContentCollectionName).add(card.ToMap());
    UpdateDeckCardCount(deckId, uid);
    return result;
  }


  void UpdateDeckCardCount(String deckId, String uid) async
  {
    var user = await GetCurrentUser(uid);
    var querySnapshot = await userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).collection(flashCardContentCollectionName).get();
    var cardCount = querySnapshot.docs.length;
    userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId).update({FlashCardDeck.fieldCardCount : cardCount});
  }

  void UpdateFilterMode(String newFilter, FlashCardDeck deck, String uid) async
  {
    var user = await GetCurrentUser(uid);
    deck.filterMode = newFilter;
    userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deck.id).update(deck.ToMap());
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
    var deckRef = userCollection.doc(user.id).collection(flashCardDecksCollectionName).doc(deckId);

    var flashcardsQuerySnapshot = await deckRef.collection(flashCardContentCollectionName).get();
    for (var docSnapshot in flashcardsQuerySnapshot.docs) {
      await docSnapshot.reference.delete();
    }
    deckRef.delete();
  }

  Future<List<FlashCardDeck>> CreateNewFlashCardDeck(FlashCardDeck newDeck, String uid) async {
    newDeck.cardCount = 0;
    newDeck.filterMode = "Default";

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
      return prefs.getString('uid');
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