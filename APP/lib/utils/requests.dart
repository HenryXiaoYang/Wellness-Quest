import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shared_preferences_service.dart';
import 'package:wellness_quest/utils/structures.dart';

class QuestRequest {
  late SharedPreferencesService pref;

  Future<void> _initializePreferences() async {
    pref = await SharedPreferencesService.getInstance();
  }

  // Change return type to Future<ProfileBasic>
  Future<ProfileBasic?> profileQuest() async {
    await _initializePreferences(); // Ensure preferences are initialized
    final String url = 'http://115.159.88.178:1111/users/profile';
    String token = pref.getToken(); // Assuming pref is an instance of your preferences service

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
        print(data); // Print the profile data for debugging

        // Directly create a ProfileBasic instance from the JSON response
        ProfileBasic profile = ProfileBasic.fromJson(data);

        print('Success: Profile fetched');
        return profile; // Return the ProfileBasic instance
      } else {
        print('Error: ${response.statusCode}');
        return null; // Return null on error
      }
    } catch (e) {
      print('Exception: $e');
      return null; // Return null on exception
    }
  }

  Future<void> completeQuest(String questId) async {
    await _initializePreferences();
    final String url = 'http://115.159.88.178:1111/quests/$questId/complete';
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
        // Handle error response
        print('Failed to complete quest: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error occurred: $e');
    }
  }
}

// Assuming ProfileBasic class is defined as follows
