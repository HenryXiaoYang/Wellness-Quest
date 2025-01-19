import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wellness_quest/utils/requests.dart';
import 'package:flutter/rendering.dart';

class QuestCard extends StatefulWidget {
  final String title;
  final String content;
  final String topic;
  final String quest_id;
  final VoidCallback onComplete; // Add a callback parameter

  const QuestCard({
    super.key,
    required this.title,
    required this.content,
    required this.topic,
    required this.quest_id,
    required this.onComplete, // Initialize the callback
  });

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  late String title;
  late String content;
  late String topic;
  late String quest_id;
  late VoidCallback onComplete;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    content = widget.content;
    topic = widget.topic;
    quest_id = widget.quest_id;
    onComplete = widget.onComplete;
  }

  Color _color(String type){
    if(type=='nutrition'){
      return Color.fromRGBO(28, 115, 190, 1);;
    } else if (type=='exercise'){
      return Color.fromRGBO(230, 50, 110, 1);;
    } else if (type=='rest'){
      return Color.fromRGBO(211, 170, 24, 1);;
    } else {
      return Color.fromRGBO(255,255,255,1);
    }
  }

  String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : ''
    ).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _color(topic).withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                capitalizeWords(topic),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 24),
            _buildCompleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Container(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : () async {
          setState(() => isLoading = true);
          final rq = QuestRequest();
          await rq.completeQuest(quest_id);
          onComplete();
          setState(() => isLoading = false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: HSLColor.fromColor(_color(topic))
              .withLightness(HSLColor.fromColor(_color(topic)).lightness * 0.75)
              .withAlpha(0.9)
              .toColor(),
          foregroundColor: Colors.white.withOpacity(0.95),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.95),
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white.withOpacity(0.95),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Complete Quest',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

