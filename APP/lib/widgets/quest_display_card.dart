import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wellness_quest/utils/requests.dart';

class QuestCard extends StatelessWidget {
  final String title;
  final String content;
  final String topic;
  final String quest_id;
  final VoidCallback onComplete; // Add a callback parameter

  QuestCard({
    super.key,
    required this.title,
    required this.content,
    required this.topic,
    required this.quest_id,
    required this.onComplete, // Initialize the callback
  });
  Color _color(String type){
    if(type=='nutrition'){
      return Color.fromRGBO(131,197,255,1);;
    } else if (type=='exercise'){
      return Color.fromRGBO(255,158,191,1);;
    } else if (type=='rest'){
      return Color.fromRGBO(218,193,103,1);;
    } else {
      return Color.fromRGBO(255,255,255,1);
    }
  }

  @override
  Widget build(BuildContext context) {
    QuestRequest rq = QuestRequest(); // Initialize QuestRequest

    return Card(
      color: _color(topic),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(content),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () async {
                await rq.completeQuest(quest_id); // Call the completeQuest method
                onComplete(); // Call the callback to notify completion
              },
              child: Text("Complete"),
            ),
          ],
        ),
      ),
    );
  }
}

