import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shared_preferences_service.dart';
import 'package:wellness_quest/utils/structures.dart';
import 'config_service.dart';

class QuestRequest {
  late SharedPreferencesService pref;

  Future<void> _initializePreferences() async {
    pref = await SharedPreferencesService.getInstance();
  }

  Future<ProfileBasic?> profileQuest() async {
    await _initializePreferences();
    final config = await ConfigService.getInstance();
    final String url = '${config.apiUrl}/users/profile';
    String token = pref.getToken();

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
        print(data);
        ProfileBasic profile = ProfileBasic.fromJson(data);
        print('Success: Profile fetched');
        return profile;
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  Future<void> completeQuest(String questId) async {
    await _initializePreferences();
    final config = await ConfigService.getInstance();
    final String url = '${config.apiUrl}/quests/$questId/complete';
    String token = pref.getToken();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data);
        print('Quest completed successfully: ${response.body}');
      } else {
        print('Failed to complete quest: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
}

// Assuming ProfileBasic class is defined as follows
