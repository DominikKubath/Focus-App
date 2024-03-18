import 'package:flutter/material.dart';
import '../Constants/ColorPalette.dart';
import 'FlashCard.dart';

class Utils {
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return ColorPalette.Red; // High priority
      case 2:
        return ColorPalette.Orange; // Medium priority
      case 1:
        return ColorPalette.Yellow; // Low priority
      default:
        return ColorPalette.Grey; // No priority
    }
  }


  Color getColorFromHex(String hexColor) {
    //Taken from https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  Color evaluateRatingColor(double value){
    if(value >= 0 && value < 0.3){
      return Colors.red;
    } else if (value >= 0.3 && value < 0.5){
      return getColorFromHex("FF6F00");
    } else if (value >= 0.5 && value < 0.6){
      return getColorFromHex("FFE400");
    } else if (value >= 0.6){
      return getColorFromHex("5cdb95");
    }

    return Colors.black;
  }

  String getLoremIpsum(){
    return "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, "
        "sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. "
        "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. "
        "At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, "
        "consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. "
        "At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. "
        "Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et "
        "iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet,";
  }

  bool isEmailOfValidFormat(String email){
    RegExp regExp = RegExp(
      r"[a-z]*@[a-z]*.[a-z]*",
      caseSensitive: false,
    );
    return regExp.hasMatch(email);
  }

  //This method Sorts FlashCards - It takes into account if they were easy for you and
  // when the last time was since you have studied them
  List<FlashCard> DefaultSortFlashCards(List<FlashCard> flashCards)
  {
    print("Input FlashCards: " + flashCards.toString());

    List<FlashCard> cardsToRepeat = flashCards
        .where((card) =>
    card.lastStatus == LastStatus.Repeat &&
        DateTime.now().difference(card.lastStudied.toDate()).inHours > 24)
        .toList();
    print("Following Cards to Repeat: " + cardsToRepeat.toString());

    List<FlashCard> hardCards = flashCards
        .where((card) => card.lastStatus == LastStatus.Hard && DateTime.now().difference(card.lastStudied.toDate()).inHours > 0.5)
        .toList();
    print("Following Hard Cards: " + hardCards.toString());

    List<FlashCard> goodCards = flashCards
        .where((card) => card.lastStatus == LastStatus.Good && DateTime.now().difference(card.lastStudied.toDate()).inHours > 2)
        .toList();
    print("Following Good Cards: " + goodCards.toString());

    List<FlashCard> easyCards = flashCards
        .where((card) => card.lastStatus == LastStatus.Easy && DateTime.now().difference(card.lastStudied.toDate()).inHours > 12)
        .toList();
    print("Following Easy Cards: " + easyCards.toString());

    List<FlashCard> newCards = flashCards
        .where((card) => card.lastStatus == LastStatus.New && DateTime.now().difference(card.lastStudied.toDate()).inHours > 0)
        .toList();
    print("Following New Cards: " + newCards.toString());

    List<FlashCard> sortedFlashCards = [
      ...cardsToRepeat,
      ...hardCards,
      ...goodCards,
      ...easyCards,
      ...newCards,
    ];
    print("Following Sorted Flashcards: " + sortedFlashCards.toString());

    if(sortedFlashCards.isEmpty)
    {
      sortedFlashCards = flashCards;
    }

    return sortedFlashCards;
  }

}