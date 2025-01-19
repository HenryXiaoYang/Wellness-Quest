import 'package:flutter/material.dart';
import 'package:wellness_quest/pages/quest_selection_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/requests.dart';
import '../utils/structures.dart';
import '../utils/shared_preferences_service.dart';
import '../widgets/quest_display_card.dart';
import 'leader_board.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late SharedPreferencesService pref;
  late ProfileBasic profile;
  String fullName = '';
  int completedQuests = 0;
  int level = 0;
  int points = 0;
  final QuestRequest qr = QuestRequest();
  bool showCelebration = false;
  List<dynamic> quests = [];
  bool isLoading = true;
  int questCnt = 0;
  List<Widget> widgets = [];

  Future<void> fetchAcceptedQuests() async {
    final String url = 'http://115.159.88.178:1111/users/accepted';
    String token = pref
        .getToken(); // Assuming you have a method to get the token
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        questCnt = data['total_accepted'];
        if (data['quests'] != null) {
          List<QuestBasic> allQuests = [];
          data['quests'].forEach((key, value) {
            if (value is List) {
              allQuests.addAll(
                  value.map((questJson) => QuestBasic.fromJson(questJson)));
            }
          });

          setState(() {
            quests = allQuests; // Store the fetched accepted quests
            isLoading = false; // Update loading state
          });
        } else {
          setState(() {
            isLoading = false; // Update loading state even if no quests found
          });
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> _initializePreferences() async {
    pref = await SharedPreferencesService.getInstance();
    await fetchAcceptedQuests(); // Fetch quests after initializing preferences
  }

  Future<void> fetchProfiles() async {
    profile = (await qr.profileQuest())!;
    fullName = profile!.full_name;
    completedQuests = profile!.completed_quests;
    level = profile!.level;
    points = profile!.points;
  }

  String _getGreeting() {
    final hour = DateTime
        .now()
        .hour;
    return hour < 12
        ? 'Good morning, $fullName. $completedQuests tasks completed!'
        : 'Good afternoon, $fullName. $completedQuests tasks completed!';
  }

  String _getAccount() {
    return 'Your current level is $level and you have $points points.';
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    fetchProfiles();
  }

  void NavigateToQuestSelectionPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const QuestSelectionPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            FutureBuilder<SharedPreferencesService>(
                future: SharedPreferencesService.getInstance(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData) {
                    pref = snapshot.data!; // Set the preferences instance
                    // Create a list of widgets from quests
                    widgets = quests.map((quest) {
                      return QuestCard(
                        title: quest.name,
                        content: quest.description,
                        topic: quest.type,
                        quest_id: quest.quest_id,
                        onComplete: () async {
                          await fetchProfiles();
                          // Remove the completed quest from the list
                          setState(() {
                            quests.remove(quest); // Remove the quest
                            questCnt = quests.length; // Update quest count
                          });
                        },
                      );
                    }).toList();
                    return SingleChildScrollView( // Make the content scrollable
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0), // Add spacing
                          Text(
                            _getAccount(),
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 16.0), // Add spacing
                          if(questCnt>0)Text(
                            "Today's quests:",
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0), // Add spacing
                          if (questCnt > 0) Column(children: widgets),
                          if (questCnt == 0)
                            ElevatedButton(
                              onPressed: () {
                                NavigateToQuestSelectionPage(context);
                              },
                              child: Text('Go to Quest Selection'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 24.0),
                                textStyle: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          SizedBox(height: 8.0),
                              ElevatedButton(
                              onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderboardPage()),
                  );
                  },
                  child: Text('View Leaderboard',
                    style: TextStyle(
                        fontSize: 16.0)),

                  ),

                  ],
                      ),
                    );
                  }
                  return Text("data is null");
                }
            ),
          ],
        )
    );
  }
}
