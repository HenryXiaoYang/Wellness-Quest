import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_preferences_service.dart';
import 'home_page.dart';

class PreferencePage extends StatefulWidget {
  const PreferencePage({super.key});

  @override
  State<StatefulWidget> createState() => IntroPageState();
}

class IntroPageState extends State<PreferencePage> {
  late SharedPreferencesService pref;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    // Load preferences here if needed
  }

  Future<void> _initializePreferences() async {
    pref = await SharedPreferencesService.getInstance();
  }

  int index = 0;
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<String> _responses = ['', '', ''];

  static const List<String> _title = [
    'Welcome!',
    'What do you eat in your daily diet?',
    'What sports do you play?',
    'When do you sleep at?',
    'Directing to homepage...'
  ];

  void NavigateToHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
    );
  }

  void clearText(int index) {
    _controllers[index].clear(); // Clear the text field for the current question
  }

  Future<void> updateUserProfile() async {
    final url = 'http://115.159.88.178:1111/auth/profile'; // API URL
    String token=pref.getToken();
    print(token);
    final response = await http.post(
      Uri.parse(url),

      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'id': 1, // Replace with actual user ID if necessary
        'username': 'string', // Replace with actual username
        'full_name': 'string', // Replace with actual full name
        'age': 20, // Replace with actual age
        'gender': 'male', // Replace with actual gender
        'nutrition_prefrence': _responses[0].split(','), // Split by comma
        'exercise_prefrence': _responses[1].split(','), // Split by comma
        'rest_prefrence': _responses[2].split(','), // Split by comma
        'completed_quests': 0,
        'level': 0,
        'points': 0,
      }),
    );

    if (response.statusCode == 200) {
      print('Profile updated successfully');
    } else {
      print('Failed to update profile: ${response.body}');
    }
  }

  @override
  void dispose() {
    // Dispose the controllers to release resources
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(3, 218, 198, 1),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title[index],
                      style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (index > 0 && index <= 3) ...[
                      SizedBox(height: 20), // Add some space before the TextField
                      TextField(
                        controller: _controllers[index - 1],
                        onChanged: (value) {
                          _responses[index - 1] = value; // Store response for questions 2, 3, and 4
                        },
                        onEditingComplete: () {
                          clearText(index - 1); // Clear the text field when editing is complete
                        },
                        decoration: InputDecoration(
                          hintText: 'Type your answer here...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    if (index == 0)
                      Text(
                        'Before we start, we would like to learn from you.',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 7,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (index != 0) {
                            clearText(index - 1); // Clear response when moving to the next question
                          }
                          index++;
                          if (index == 4) {
                            updateUserProfile().then((_) {
                              NavigateToHomePage(context);
                            });
                          }
                          // Prevents incrementing beyond the limit
                          if (index > 4) {
                            index = 4; // Keep it at the last index
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 30, color: Color.fromRGBO(3, 218, 198, 1)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
