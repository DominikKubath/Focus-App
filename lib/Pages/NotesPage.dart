import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studienarbeit_focus_app/Pages/DocumentPage.dart';
import 'package:studienarbeit_focus_app/UI%20Elements/MenuDrawer.dart';

import '../Classes/NoteDoc.dart';
import '../FirestoreManager.dart';
import '../NotesManager.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Future<List<NoteDoc>> usersDocs;
  late Future<List<NoteDoc>> sharedDocs;

  @override
  Widget build(BuildContext context) {
    usersDocs = _getAllDocuments();
    sharedDocs = _getSharedDocuments();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      drawer: MenuDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Show shared documents
            FutureBuilder<List<NoteDoc>>(
              future: sharedDocs,
              builder: (context, sharedDocumentsSnapshot) {
                if (sharedDocumentsSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while fetching shared documents
                } else if (sharedDocumentsSnapshot.hasError) {
                  return Text(
                    'Error: ${sharedDocumentsSnapshot.error}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ); // Show error message if fetching shared documents fails
                } else {
                  final sharedDocuments = sharedDocumentsSnapshot.data ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Documents Shared by Other Users',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      // Display shared documents here using sharedDocuments list
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8, // Number of columns in the grid
                          mainAxisSpacing: 8.0, // Spacing between rows
                          crossAxisSpacing: 8.0, // Spacing between columns
                        ),
                        itemCount: sharedDocuments.length,
                        itemBuilder: (context, index) {
                          return _buildDocumentItem(sharedDocuments[index]);
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            // Show user's documents
            FutureBuilder<List<NoteDoc>>(
              future: usersDocs,
              builder: (context, userDocumentsSnapshot) {
                if (userDocumentsSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator while fetching user documents
                } else if (userDocumentsSnapshot.hasError) {
                  return Text(
                    'Error: ${userDocumentsSnapshot.error}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ); // Show error message if fetching user documents fails
                } else {
                  final userDocuments = userDocumentsSnapshot.data ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Your Documents',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0), // Add padding to the end of the text
                            child: ElevatedButton(
                              onPressed: () {
                                // Add functionality to the button here
                              },
                              child: Text('Add Document'),
                            ),
                          ),
                        ],
                      ),
                      // Display user's documents here using userDocuments list
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8, // Number of columns in the grid
                          mainAxisSpacing: 8.0, // Spacing between rows
                          crossAxisSpacing: 8.0, // Spacing between columns
                        ),
                        itemCount: userDocuments.length,
                        itemBuilder: (context, index) {
                          return _buildDocumentItem(userDocuments[index]);
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(NoteDoc doc) {
    return Card(
      child: InkWell(
        onTap: () async {
          QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
              .collection('user')
              .where("uid", isEqualTo: doc.ownerId)  // Filter by ownerId
              .limit(1)
              .get();

          DocumentReference docRef;

          if (userQuerySnapshot.docs.isNotEmpty) {
            String userId = userQuerySnapshot.docs[0].id;
            docRef = FirebaseFirestore.instance
                .collection('user')
                .doc(userId)
                .collection("notes")
                .doc(doc.docId);
            Stream<DocumentSnapshot> documentStream = docRef.snapshots();
            debugPrint(docRef.get().toString());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentPage(document: doc, documentStream: documentStream), // Pass the document to the details page
              ),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              doc.docName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Icon(
              Icons.description,
              size: 64.0,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Future<List<NoteDoc>> _getAllDocuments() async {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      var documents = await NotesManager().GetAllDocumentsOfUser(userId);

      return documents;
    } else {
      return [];
    }
  }

  Future<List<NoteDoc>> _getSharedDocuments() async {
    String? userId = await FirestoreManager().ReadUid(context);
    if (userId != null) {
      var documents = await NotesManager().GetAllSharedDocuments(userId);

      return documents;
    } else {
      return [];
    }
  }
}

class DocumentDetailsPage extends StatelessWidget {
  final NoteDoc document;

  DocumentDetailsPage({required this.document});

  @override
  Widget build(BuildContext context) {
    // Implement document details page UI here
    return Scaffold(
      appBar: AppBar(
        title: Text(document.docName),
      ),
      body: Center(
        child: Text('Document Details'),
      ),
    );
  }
}
