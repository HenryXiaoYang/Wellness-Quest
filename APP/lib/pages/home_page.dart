import 'package:flutter/material.dart';
import 'package:wellness_quest/pages/quest_selection_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/requests.dart';
import '../utils/structures.dart';
import '../utils/shared_preferences_service.dart';
import '../widgets/quest_display_card.dart';
import 'leader_board.dart';
import '../utils/config_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
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
    final config = await ConfigService.getInstance();
    final String url = '${config.apiUrl}/users/accepted';
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
    final hour = DateTime.now().hour;
    return hour < 12
        ? 'Good morning, $fullName.\n$completedQuests quests completed!'
        : 'Good afternoon, $fullName.\n$completedQuests quests completed!  ';
  }

  String _getAccount() {
    return 'Your are currently level $level and you have $points points.';
  }

  String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : ''
    ).join(' ');
  }

  @override
  void initState() {
    super.initState();
    // Delay the observer registration to ensure framework is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(this);
    });
    _initializePreferences();
    fetchProfiles();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
    final themeColor = Color.fromRGBO(3, 218, 198, 1);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeColor.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              bottom: false,  // Don't add safe area padding at bottom
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 140.0),  // Increased bottom padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: themeColor.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: 24.0, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                // New Level and Points visualization
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: themeColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Level $level',
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: themeColor,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.stars,
                                                  color: themeColor,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            LinearProgressIndicator(
                                              value: (completedQuests % 5) / 5, // 5 tasks per level
                                              backgroundColor: Colors.white,
                                              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                              minHeight: 8,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '$points points',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.0),
                          if (questCnt > 0) ...[
                            Text(
                              "Today's quests:",
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            ...quests.map((quest) => Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: QuestCard(
                                topic: quest.type,
                                title: quest.name,
                                content: quest.description,
                                quest_id: quest.quest_id.toString(),
                                onComplete: () {
                                  setState(() {
                                    fetchAcceptedQuests();
                                    fetchProfiles();
                                  });
                                },
                              ),
                            )).toList(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(  // Changed Container to Padding
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      if (questCnt < 3)
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              NavigateToQuestSelectionPage(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Select More Quests',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LeaderboardPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: themeColor, width: 2),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'View Leaderboard',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
