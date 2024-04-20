import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';

import 'Classes/NoteDoc.dart';
import 'Classes/SharedDoc.dart';

class NotesManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference userCollection = _firestore.collection("user");

  static const String notesCollectionName = "notes";
  static const String sharedNotesCollectionName = "sharedDocs";

  Future<List<NoteDoc>> GetAllDocumentsOfUser(String uid) async
  {
    var userDocument = await userCollection.where("uid", isEqualTo: uid).get();
    return await userCollection.doc(userDocument.docs[0].id).collection(notesCollectionName).get().then((value){
      List<NoteDoc> notes = [];
      value.docs.forEach((element) {
        debugPrint("GOT NOTE " + element.data().toString());
        var note = NoteDoc.fromDoc(element);
        note.ownerId = uid;
        notes.add(note);
        debugPrint("NoteDoc: " + note.docName.toString());
        debugPrint("NoteDoc: " + note.content.toString());
        debugPrint("NoteDoc: " + note.docId.toString());
        debugPrint("NoteDoc: " + note.ownerId.toString());
      });
      return notes;
    });
  }

  Future<List<NoteDoc>> GetAllSharedDocuments(String uid) async
  {
    var userDocument = await userCollection.where("uid", isEqualTo: uid).get();
    List<NoteDoc> sharedDocs = [];

    for (var element in userDocument.docs) {
      var sharedCollection = userCollection.doc(element.id).collection(sharedNotesCollectionName);
      var sharedDocsSnapshots = await sharedCollection.get();

      for (var sharedDocSnapshot in sharedDocsSnapshots.docs) {
        var shared = SharedDoc.fromDoc(sharedDocSnapshot);
        var sharingUserDocSnapshot = await userCollection.where("uid", isEqualTo: shared.sharedBy).limit(1).get();
        var sharingUserDoc = sharingUserDocSnapshot.docs.first;
        debugPrint("Sharing User Doc First: " + sharingUserDoc.data().toString());

        var subcollection = sharingUserDoc.reference.collection(notesCollectionName); // Navigate to subcollection
        var retrievedDocumentSnapshot = await subcollection.doc(shared.sharedDocId).get();

        var noteDoc = NoteDoc.fromDoc(retrievedDocumentSnapshot);
        debugPrint("Shared Doc: " + noteDoc.docName.toString());
        debugPrint("Shared Doc: " + noteDoc.content.toString());
        noteDoc.ownerId = shared.sharedBy;
        sharedDocs.add(noteDoc);
      }
    }
    return sharedDocs;
  }

  Future<DocumentReference<Map<String, dynamic>>> CreateDocument(String uid) async
  {
    var user = await FirestoreManager().GetCurrentUser(uid);
    var doc = NoteDoc.empty();
    doc.docName = "";
    doc.content = "";
    return userCollection.doc(user.id).collection(notesCollectionName).add(doc.ToMap());
  }

  void UpdateDocumentContent(String docId, String newContent, String uid) async
  {
    var user = await FirestoreManager().GetCurrentUser(uid);
    userCollection.doc(user.id).collection(notesCollectionName).doc(docId).update({"content" : newContent});
  }

  void UpdateDocumentName(String docId, String newName, String uid) async
  {
    var user = await FirestoreManager().GetCurrentUser(uid);
    userCollection.doc(user.id).collection(notesCollectionName).doc(docId).update({"name" : newName});
  }


  //email is the email address of the user that the access is given to
  //NoteId is the ID of the Shared Document
  //uid is always the id of the current user
  Future<Future<DocumentReference<Map<String, dynamic>>>> GiveAccessToDocument(String noteId, String email, String uid) async
  {
    var snapshot = await userCollection.where("email", isEqualTo: email).limit(1).get();
    var userDoc = snapshot.docs.first;

    Map<String, dynamic> sharedDoc = {
      SharedDoc.sharedByFieldName : uid,
      SharedDoc.sharedDocFieldName : noteId,
    };

    return userCollection.doc(userDoc.id).collection(sharedNotesCollectionName).add(sharedDoc);
  }

}
