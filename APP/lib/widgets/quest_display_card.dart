import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class QuestCard extends StatelessWidget{
  final String title;
  final String content;
  final String topic;

  QuestCard({super.key,required this.title, required this.content, required this.topic});

  @override
  Widget build(context) {
    return Card(
      child: Column(
        children: [
          Text(topic),
          Text(title),
          Text(content),
        ],
      )
    );
  }

}