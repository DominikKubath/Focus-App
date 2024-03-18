import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studienarbeit_focus_app/Classes/FlashCard.dart';

class Attempt
{
  late Timestamp attemptStart;
  late Timestamp attemptEnd;
  late LastStatus status;

  static const String fieldAttemptStart = "attemptStart";
  static const String fieldAttemptEnd = "attemptEnd";
  static const String fieldAttemptStatus = "attemptStatus";

  Attempt.empty();

  Attempt.fromDoc(DocumentSnapshot doc)
  {
    attemptStart = doc[Attempt.fieldAttemptStart];
    attemptEnd = doc[Attempt.fieldAttemptEnd];
    status = LastStatus.values.firstWhere(
          (status) => status.name.toString() == '${doc[Attempt.fieldAttemptStatus]}',
      orElse: () => LastStatus.New,
    );
  }

  Map<String, dynamic> ToMap()
  {
    return {
      fieldAttemptStart : attemptStart,
      fieldAttemptEnd : attemptEnd,
      fieldAttemptStatus : status.name.toString()
    };
  }
}