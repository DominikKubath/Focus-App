import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studienarbeit_focus_app/UI Elements/MenuDrawer.dart';
import 'package:studienarbeit_focus_app/Classes/NoteDoc.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';

class DocumentPage extends StatefulWidget {
  final NoteDoc document;
  final Stream<DocumentSnapshot> documentStream;

  const DocumentPage({Key? key, required this.document, required this.documentStream}) : super(key: key);

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.docName);
    _contentController = TextEditingController(text: widget.document.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter document title',
          ),
          style: TextStyle(
            color: Colors.black,
          ),
          onChanged: (newTitle) {
            // Update title in database
            //FirestoreManager().updateDocumentTitle(widget.document.docId, newTitle);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add functionality for the button here
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      drawer: MenuDrawer(),
      body: StreamBuilder(
        stream: widget.documentStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var documentData = snapshot.data as DocumentSnapshot;
          var content = documentData['content'] as String;

          _contentController.text = content;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter document content',
                    ),
                    onChanged: (newContent) {
                      // Update content in database
                      //FirestoreManager().updateDocumentContent(widget.document.docId, newContent);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
