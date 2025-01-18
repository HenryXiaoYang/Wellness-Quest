import 'package:flutter/material.dart';

import '../utils/shared_preferences_service.dart';
import '../widgets/quest_display_card.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  List <Widget> widgets = [];
  late SharedPreferencesService pref;
  late int index;

  void loadSettings([SharedPreferencesService? preferences]) {
    pref=preferences!;
    index= pref.getIndex();
  }

  @override
  Widget build(BuildContext context) {
    String _getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Good morning';
      } else {
        return 'Good afternoon';
      }
    }
    widgets.clear();
    for(int i=1; i<index; i++){
        widgets.add(QuestCard(title: pref.getNotes(i)![0],content:pref.getNotes(i)![1],topic:pref.getNotes(i)![2]));
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
          children: [
            // Greeting text
            Text(
              _getGreeting(), // Call the function to get the greeting
              style: TextStyle(fontSize: 16.0), // Set the font size
            ),
            Text(
              "Today's quests:", // Call the function to get the greeting
              style: TextStyle(fontSize: 24.0,fontWeight: FontWeight.bold), // Set the font size
            ),
            if(index>1) Column(children: widgets)
            // Other widgets can go here
          ],
        ),
      ),
    );
  }
}