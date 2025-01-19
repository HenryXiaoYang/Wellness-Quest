import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/shared_preferences_service.dart';

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
    final String url = 'http://115.159.88.178:1111/leaderboard'; // Ensure the correct endpoint is used
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: leaderboard.length,
        itemBuilder: (context, index) {
          final user = leaderboard[index];
          String name=user.fullName;
          if(name=='string'||name=='')name='anonymous';
          return ListTile(
            leading: CircleAvatar(
              child: Text((index + 1).toString()), // Rank
            ),
            title: Text(name),
            subtitle: Text('Points: ${user.points}'),
          );
        },
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
