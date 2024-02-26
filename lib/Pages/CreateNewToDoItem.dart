import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studienarbeit_focus_app/Classes/ToDoItem.dart';
import 'package:studienarbeit_focus_app/Pages/ToDoListPage.dart';
//import 'package:studienarbeit_focus_app/Pages/ToDoItemPage.dart';

//import '../Classes/UserInfo.dart';
import '../FirestoreManager.dart';

class CreateNewToDoPage extends StatefulWidget {
  const CreateNewToDoPage({Key? key}) : super(key: key);

  @override
  _CreateNewToDoPageState createState() => _CreateNewToDoPageState();
}

class _CreateNewToDoPageState extends State<CreateNewToDoPage> {
  TextEditingController newToDoNameController = TextEditingController();
  TextEditingController newToDoDescriptionController = TextEditingController();
  TextEditingController newToDoPriorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Text("Enter the title of the to-do",
                style: GoogleFonts.montserrat(fontSize: 48),
                textAlign: TextAlign.center,),
            ),
            Container(
              width: screenWidth,
              margin: const EdgeInsets.fromLTRB(40, 0, 40, 10),
              child: TextFormField(controller: newToDoNameController,
                decoration: InputDecoration(hintText: "Example: Grocery Shopping",
                    hintStyle: GoogleFonts.montserrat(color: Colors.grey)),
                keyboardType: TextInputType.text,),
            ),
            Container(
              width: screenWidth,
              margin: const EdgeInsets.fromLTRB(40, 0, 40, 10),
              child: TextFormField(controller: newToDoDescriptionController,
                decoration: InputDecoration(hintText: "Description",
                    hintStyle: GoogleFonts.montserrat(color: Colors.grey)),
                keyboardType: TextInputType.text,),
            ),
            Container(
              width: screenWidth,
              margin: const EdgeInsets.fromLTRB(40, 0, 40, 10),
              child: TextFormField(controller: newToDoPriorityController,
                decoration: InputDecoration(hintText: "Priority (0-3)",
                    hintStyle: GoogleFonts.montserrat(color: Colors.grey)),
                keyboardType: TextInputType.number,),
            ),
            Container(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      String? uid = await FirestoreManager().ReadUid(context);
                      ToDoItem todo = ToDoItem.empty();
                      todo.name = newToDoNameController.text;
                      todo.description = newToDoDescriptionController.text;
                      int? priority = int.tryParse(newToDoPriorityController.text);
                      if(priority != null && priority >= 0 && priority <= 3) {
                        todo.priority = priority;
                      }
                      FirestoreManager().CreateNewToDo(todo, uid!);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ToDoListPage(),
                          ),
                              (Route<dynamic> route) => false);
                    } catch (e) {

                    }
                  },
                  child: Text('Create To-Do'),
                )
            ),
          ],
        )
    );
  }
}

