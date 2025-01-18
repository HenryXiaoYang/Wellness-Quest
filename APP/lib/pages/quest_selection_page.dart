import 'package:flutter/material.dart';

import '../utils/shared_preferences_service.dart';
import '../widgets/quest_display_card.dart';

class QuestSelectionPage extends StatefulWidget{
  const QuestSelectionPage({super.key});

  @override
  State<StatefulWidget> createState() => QuestSelectionPageState();
}

class QuestSelectionPageState extends State<QuestSelectionPage>{
  late SharedPreferencesService pref;
  late int index;

  void loadSettings([SharedPreferencesService? preferences]) {
    pref=preferences!;
    index= pref.getIndex();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select the quests for today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Quest Card
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topic (nutrition/exercise/sleep)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Quest name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cross Sign Button
              ElevatedButton(
                onPressed: () {
                  // Handle cross action
                  print('Cross Sign Pressed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(Icons.close,color: Colors.white)
                ),
              ),
              const SizedBox(width: 20.0),

              // Check Sign Button
              ElevatedButton(
                onPressed: () {
                  // Handle check action
                  print('Check Sign Pressed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: const CircleBorder(),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(Icons.check,color: Colors.white)
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}