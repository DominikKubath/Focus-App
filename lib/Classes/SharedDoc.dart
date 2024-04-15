import 'package:cloud_firestore/cloud_firestore.dart';

class SharedDoc
{
  late String docId;
  //SharedBy is the ID of the User that shared the document
  late String sharedBy;
  late String sharedDocId;

  static const String sharedByFieldName = "sharedBy";
  static const String sharedDocFieldName = "docId";

  SharedDoc.empty();

  SharedDoc.fromDoc(DocumentSnapshot doc)
  {
    docId = doc.id;
    sharedBy = doc[sharedByFieldName];
    sharedDocId = doc[sharedDocFieldName];
  }

  Map<String, dynamic> ToMap()
  {
    return {
      sharedByFieldName : sharedBy,
      sharedDocFieldName : sharedDocId
    };
  }

}