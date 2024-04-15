import 'package:cloud_firestore/cloud_firestore.dart';

class NoteDoc
{
  late String docId;
  late String docName;
  late String content;
  late String ownerId;

  static const String nameFieldName = "name";
  static const String contentFieldName = "content";

  NoteDoc.empty();

  NoteDoc.fromDoc(DocumentSnapshot doc)
  {
    docId = doc.id;
    docName = doc[nameFieldName];
    content = doc[contentFieldName];
  }

  Map<String, dynamic> ToMap()
  {
    return {
      nameFieldName : docName,
      contentFieldName : content
    };
  }

}
/*
//SharedBy is the Id of the User that shared the document
late String sharedBy;
late String sharedDocId;

static const String sharedByFieldName = "" */