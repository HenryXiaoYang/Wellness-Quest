import 'package:flutter/material.dart';
import 'package:wellness_quest/pages/preference_page.dart';
import 'package:wellness_quest/pages/sign_up.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/shared_preferences_service.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late SharedPreferencesService pref;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    pref = await SharedPreferencesService.getInstance();
  }

  void NavigateToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  void NavigateToPreferencePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PreferencePage()),
          (route) => false,
    );
  }

  Future<void> _authenticate(String username, String password) async {
    final String url = 'http://115.159.88.178:1111/auth/login';

    // Prepare the body in x-www-form-urlencoded format
    final Map<String, String> data = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: data, // Use the Map directly as the body
      );

      if (response.statusCode == 200) {
        // Handle successful authentication
        final responseData = json.decode(response.body);
        String token = responseData['access_token']; // Assuming the token is returned in the response
        pref.storeToken(token);
        print('Login successful! Token: $token');
        NavigateToPreferencePage(); // Navigate to the preference page
      } else {
        // Handle error response
        print('Login failed: ${response.body}');
        // Optionally show an alert or snackbar to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.body}')),
        );
      }
    } catch (error) {
      print('Error occurred: $error');
      // Optionally show an alert or snackbar to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color.fromRGBO(3, 218, 198, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String username = usernameController.text;
                String password = passwordController.text;
                print('Username: $username, Password: $password');

                await _authenticate(username, password);
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                NavigateToSignUpPage();
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
