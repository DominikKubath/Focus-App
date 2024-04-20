import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studienarbeit_focus_app/UI Elements/MenuDrawer.dart';
import 'package:studienarbeit_focus_app/Classes/NoteDoc.dart';
import 'package:studienarbeit_focus_app/FirestoreManager.dart';

import '../NotesManager.dart';

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
  late int _startCursorPosition;
  late int _textLengthBeforeChange;
  late Timer _debounceTimer;
  bool _isTyping = false;
  final Color primaryColor = Color(0xFF009688);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.docName);
    _contentController = TextEditingController(text: widget.document.content);
    _startCursorPosition = _contentController.selection.baseOffset;
    _textLengthBeforeChange = _contentController.text.length;

    // Add listener to content controller to update cursor position
    _contentController.addListener(_onTextChange);
    _debounceTimer = Timer(Duration(milliseconds: 500), () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
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
                  NotesManager().UpdateDocumentName(widget.document.docId, newTitle, widget.document.ownerId);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0), // Add left padding to the button
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                child: TextButton(
                  onPressed: () {
                    _showCollaboratePopup(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor, // Add background color
                  ),
                  child: Text(
                    'Collaborate',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: MenuDrawer(),
      body: StreamBuilder(
        stream: widget.documentStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var documentData = snapshot.data as DocumentSnapshot;
          var content = documentData['content'] as String?;

          // Update content in the text controller only if user is not typing
          if (!_isTyping) {
            _contentController.value = TextEditingValue(
              text: content ?? '',
              selection: TextSelection.collapsed(
                offset: _startCursorPosition + (_contentController.text.length - _textLengthBeforeChange),
              ),
            );
          }

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
                      setState(() {
                        _isTyping = true;
                      });
                      _debounceTimer.cancel();
                      _debounceTimer = Timer(Duration(milliseconds: 200), () {
                        setState(() {
                          _isTyping = false;
                          _textLengthBeforeChange = _contentController.text.length;
                          _startCursorPosition = _contentController.selection.baseOffset;
                        });
                      });
                      // Update content in database
                      NotesManager().UpdateDocumentContent(widget.document.docId, newContent, widget.document.ownerId);
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

  void _showCollaboratePopup(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Collaborate on this document...'),
          content: TextField(
            controller: emailController,
            // TextField for entering email address
            decoration: InputDecoration(hintText: 'Enter email address'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                var noteId = widget.document.docId;
                var uid = widget.document.ownerId;

                var result = await NotesManager().GiveAccessToDocument(noteId, emailController.text, uid);

                Navigator.of(context).pop();

                if (result != null) {
                  // Show a SnackBar if sharing was successful
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Document shared successfully!'),
                      duration: Duration(seconds: 2), // Adjust duration as needed
                    ),
                  );
                } else {
                  // Handle sharing failure
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to share document.'),
                      duration: Duration(seconds: 2), // Adjust duration as needed
                    ),
                  );
                }
              },
              child: Text('Give Access'),
            ),
          ],
        );
      },
    );
  }

  // Function to update cursor position
  void _onTextChange() {
    if (!_isTyping) {
      _startCursorPosition = _contentController.selection.baseOffset;
      _textLengthBeforeChange = _contentController.text.length;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    // Remove listener to avoid memory leaks
    _contentController.removeListener(_onTextChange);
    super.dispose();
  }
}

