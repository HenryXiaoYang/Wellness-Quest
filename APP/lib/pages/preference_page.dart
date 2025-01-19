import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/shared_preferences_service.dart';
import 'home_page.dart';
import '../utils/config_service.dart';

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
    _initializeAndLoadPreferences();
  }

  Future<void> _initializeAndLoadPreferences() async {
    await _initializePreferences();
    await _loadExistingPreferences();
  }

  Future<void> _initializePreferences() async {
    pref = await SharedPreferencesService.getInstance();
  }

  bool _isLoading = true;  // Add this flag to track loading state

  Future<void> _loadExistingPreferences() async {
    final config = await ConfigService.getInstance();
    final String baseUrl = '${config.apiUrl}/auth';
    String token = pref.getToken();
    
    if (token.isEmpty) {
      setState(() {
        _isLoading = false;  // No token, stop loading
      });
      return;
    }

    try {
      final profileResponse = await http.get(
        Uri.parse('${config.apiUrl}/users/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (profileResponse.statusCode == 200) {
        final profile = jsonDecode(profileResponse.body);
        setState(() {
          // Convert arrays back to comma-separated strings
          _controllers[0].text = (profile['nutrition_prefrence'] as List?)?.join(',') ?? '';
          _controllers[1].text = (profile['exercise_prefrence'] as List?)?.join(',') ?? '';
          _controllers[2].text = (profile['rest_prefrence'] as List?)?.join(',') ?? '';
          
          // Update responses as well
          _responses[0] = _controllers[0].text;
          _responses[1] = _controllers[1].text;
          _responses[2] = _controllers[2].text;
          
          _isLoading = false;  // Mark loading as complete
        });
      } else {
        print('Failed to load preferences: ${profileResponse.statusCode}');
        setState(() {
          _isLoading = false;  // Stop loading on error
        });
      }
    } catch (e) {
      print('Error loading preferences: $e');
      setState(() {
        _isLoading = false;  // Stop loading on error
      });
    }
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
    'What you do in your free time?',
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
    final config = await ConfigService.getInstance();
    final String baseUrl = '${config.apiUrl}/auth';
    String token = pref.getToken();
    
    // First, get the current user profile
    final profileResponse = await http.get(
      Uri.parse('${config.apiUrl}/users/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (profileResponse.statusCode != 200) {
      print('Failed to get profile: ${profileResponse.body}');
      return;
    }

    // Parse the existing profile data
    final existingProfile = jsonDecode(profileResponse.body);
    print('Existing profile: $existingProfile');

    // Update profile with new preferences while keeping existing data
    final response = await http.post(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        ...existingProfile, // Keep all existing profile data
        'nutrition_prefrence': _responses[0].split(','),
        'exercise_prefrence': _responses[1].split(','),
        'rest_prefrence': _responses[2].split(','),
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
    final themeColor = Color.fromRGBO(3, 218, 198, 1);
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: Text(
                              _title[index],
                              key: ValueKey<int>(index),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          if (index == 0) ...[
                            Text(
                              'Before we start, we would like to learn from you.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ],
                          if (index > 0 && index <= 3) ...[
                            SizedBox(height: 32),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeColor.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _controllers[index - 1],
                                onChanged: (value) {
                                  _responses[index - 1] = value;
                                },
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Type your answer here...',
                                  hintStyle: TextStyle(color: Colors.black38),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.all(20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: themeColor.withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: themeColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (index == 0) ...[
                          Container(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                NavigateToHomePage(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: themeColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Skip for now',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        Container(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (index != 0) {
                                  clearText(index - 1);
                                }
                                index++;
                                if (index == 4) {
                                  updateUserProfile().then((_) {
                                    NavigateToHomePage(context);
                                  });
                                }
                                if (index > 4) {
                                  index = 4;
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              index < 3 ? 'Next' : 'Finish',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
