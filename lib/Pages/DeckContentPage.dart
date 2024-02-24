import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../UI Elements/MenuDrawer.dart';

class DeckContentPage extends StatefulWidget {
  final String id;
  const DeckContentPage({Key? key, required this.id}) : super(key: key);
  @override
  _DeckContentPageState createState() => _DeckContentPageState();
}

class _DeckContentPageState extends State<DeckContentPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flash Cards'),
      ),
      drawer: MenuDrawer(),
      body: Container(
        child: Center(
          child: Text('Flash Cards'),
        ),
      ),
    );
  }
}