import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';

import 'Classes/Score.dart';


class ScoreManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference userCollection = _firestore.collection("user");

  static const String scoreCollectionName = "scores";

  Future<Score?> GetTodaysScore(String uid) async
  {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if(userDoc != null)
    {
      try {
        DateTime today = DateTime.now();
        DateTime startOfToday = DateTime(today.year, today.month, today.day);
        QuerySnapshot querySnapshot = await userCollection
            .doc(userDoc.id)
            .collection(scoreCollectionName)
            .where(Score.dateFieldName, isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
            .where(Score.dateFieldName, isLessThan: Timestamp.fromDate(startOfToday.add(Duration(days: 1))))
            .limit(1)
            .get();

        debugPrint(Score.fromDoc(querySnapshot.docs.first).docId);
        if (querySnapshot.docs.isNotEmpty) {
          return Score.fromDoc(querySnapshot.docs.first);
        } else {
          return null;
        }
      } catch (e) {
        print("Error fetching today's score: $e");
        return null;
      }
    }
  }

  void UpdateTodaysScore(int amount, String uid) async {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        Score? todayScore = await GetTodaysScore(uid);
        if (todayScore == null) {
          CreateTodaysScoreIfNotExisting(uid, amount);
        } else {
          int updatedAmount = todayScore.amount + amount;
          await userCollection
              .doc(userDoc.id)
              .collection(scoreCollectionName)
              .doc(todayScore.docId)
              .update({Score.amountFieldName: updatedAmount});
        }
      } catch (e) {
        print("Error updating today's score: $e");
      }
    }
  }


  void CreateTodaysScoreIfNotExisting(String uid, int initialAmount) async {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        DateTime startOfToday = DateTime(today.year, today.month, today.day);
        Score? todayScore = await GetTodaysScore(uid);
        if (todayScore == null) {
          await userCollection.doc(userDoc.id).collection(scoreCollectionName).add({
            Score.amountFieldName: initialAmount,
            Score.dateFieldName: Timestamp.fromDate(startOfToday)
          });
        }
      } catch (e) {
        print("Error creating today's score: $e");
      }
    }
  }


  Future<List<Score>?> GetScoresOfLastSevenDays(String uid) async {
    var userDoc = await FirestoreManager().GetCurrentUser(uid);
    if (userDoc != null) {
      try {
        DateTime today = DateTime.now();
        DateTime sevenDaysAgo = today.subtract(Duration(days: 7));

        QuerySnapshot querySnapshot = await userCollection
            .doc(userDoc.id)
            .collection(scoreCollectionName)
            .where(Score.dateFieldName, isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
            .where(Score.dateFieldName, isLessThan: Timestamp.fromDate(today))
            .orderBy(Score.dateFieldName, descending: true)
            .get();

        List<Score> scores = querySnapshot.docs.map((doc) => Score.fromDoc(doc)).toList();

        // Check for missing dates and add dummy scores
        for (int i = 0; i < 7; i++) {
          DateTime dateToCheck = today.subtract(Duration(days: i));
          bool dateExists = scores.any((score) => score.date.toDate().year == dateToCheck.year && score.date.toDate().month == dateToCheck.month && score.date.toDate().day == dateToCheck.day);
          if (!dateExists) {
            // Create a dummy score with amount 0 for missing date
            Score dummyScore = Score.empty();
            dummyScore.docId = '';
            dummyScore.date = Timestamp.fromDate(dateToCheck);
            dummyScore.amount = 0;
            scores.add(dummyScore);
          }
        }

        // Sort the list by date
        scores.sort((a, b) => a.date.compareTo(b.date));

        return scores;
      } catch (e) {
        print("Error fetching scores of last seven days: $e");
        return null;
      }
    }
  }



}
