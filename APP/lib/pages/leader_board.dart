import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/shared_preferences_service.dart';
import '../utils/config_service.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<UserProfile> leaderboard = [];
  bool isLoading = true;
  late SharedPreferencesService pref;

  Future<void> _initializePreferences() async {
    pref = await SharedPreferencesService.getInstance();
    fetchLeaderboard();
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> fetchLeaderboard() async {
    final config = await ConfigService.getInstance();
    final String url = '${config.apiUrl}/leaderboard';
    String token = pref.getToken(); // Get the token after initialization
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Check if 'leaderboard' key exists and is not null
        if (data['leaderboard'] != null) {
          setState(() {
            leaderboard = (data['leaderboard'] as List)
                .map((userJson) => UserProfile.fromJson(userJson))
                .toList();
            isLoading = false;
          });
        } else {
          print('Error: leaderboard key is null');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Color.fromRGBO(3, 218, 198, 1);
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: themeColor))
                    : leaderboard.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No rankings yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: leaderboard.length,
                            itemBuilder: (context, index) {
                              final user = leaderboard[index];
                              String name = user.fullName;
                              if (name == 'string' || name == '') name = 'anonymous';
                              
                              // Top 3 players get special treatment
                              final bool isTopThree = index < 3;
                              final List<Color> topColors = [
                                Color(0xFFFFD700), // Gold
                                Color(0xFFC0C0C0), // Silver
                                Color(0xFFCD7F32), // Bronze
                              ];
                              
                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeColor.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isTopThree
                                          ? topColors[index].withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: isTopThree
                                          ? Icon(
                                              Icons.emoji_events,
                                              color: topColors[index],
                                              size: 24,
                                            )
                                          : Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        'Level ${user.level}',
                                        style: TextStyle(
                                          color: themeColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${user.points} points',
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: themeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${user.completedQuests} quests',
                                      style: TextStyle(
                                        color: themeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserProfile {
  final String username;
  late final String fullName;
  final int level;
  final int completedQuests;
  final int points;

  UserProfile({
    required this.username,
    required this.fullName,
    required this.level,
    required this.completedQuests,
    required this.points,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      fullName: json['full_name'],
      level: json['level'],
      completedQuests: json['completed_quests'],
      points: json['points'],
    );
  }
}
