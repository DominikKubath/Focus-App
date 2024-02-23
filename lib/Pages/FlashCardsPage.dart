import 'package:flutter/material.dart';
import '../UI Elements/MenuDrawer.dart';

class FlashCardsPage extends StatefulWidget {
  @override
  _FlashCardsPageState createState() => _FlashCardsPageState();
}

class _FlashCardsPageState extends State<FlashCardsPage> {

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
