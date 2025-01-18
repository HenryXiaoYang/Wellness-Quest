import 'package:flutter/material.dart';
import 'package:wellness_quest/pages/quest_selection_page.dart';

import '../utils/shared_preferences_service.dart';
import '../widgets/quest_display_card.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Widget> widgets = [];
  late SharedPreferencesService pref;
  int index = 0; // Initialize index to a default value

  void NavigateToQuestSelectionPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const QuestSelectionPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    String _getGreeting() {
      final hour = DateTime.now().hour;
      return hour < 12 ? 'Good morning' : 'Good afternoon';
    }

    return Scaffold(
      body: FutureBuilder<SharedPreferencesService>(
        future: SharedPreferencesService.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            pref = snapshot.data!; // Set the preferences instance
            index = pref.getIndex(); // Get the index from preferences

            widgets.clear();
            for (int i = 1; i < index; i++) {
              widgets.add(QuestCard(
                title: pref.getNotes(i)![0],
                content: pref.getNotes(i)![1],
                topic: pref.getNotes(i)![2],
              ));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    "Today's quests:",
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  if (index > 1) Column(children: widgets),
                  if (index == 1)
                    ElevatedButton(
                      onPressed: () {
                        NavigateToQuestSelectionPage(context);
                      },
                      child: Text('Go to Quest Selection'), // Provide a child for the button
                    ),
                ],
              ),
            );
          }

          return Center(child: Text("Data is null")); // Handle null data case
        },
      ),
    );
  }
}
