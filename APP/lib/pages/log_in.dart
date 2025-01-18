import 'package:flutter/material.dart';
import 'package:wellness_quest/pages/preference_page.dart';
import 'package:wellness_quest/pages/sign_up.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<LogInPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void NavigateToSignUpPage(context) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignUpPage()),
              (route) => false
      );
    }
    void NavigateToPreferencePage(context) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PreferencePage()),
              (route) => false
      );
    }
    Future<void> _authenticate(String username, String password) async {
      final String url = 'https://127.0.0.1:8000'; // Replace with your server URL

      final Map<String, String> data = {
        'username': username,
        'password': password,
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(data),
        );

        if (response.statusCode == 200) {
          // Handle successful authentication
          final responseData = json.decode(response.body);
          String token = responseData['token']; // Assuming the token is returned in the response
          print('Login successful! Token: $token');
          // Navigate to the next screen or save the token
          NavigateToPreferencePage(context); // Implement this function to navigate to the home page
        } else {
          // Handle error response
          print('Login failed: ${response.body}');
          // Optionally show an alert or snackbar to the user
        }
      } catch (error) {
        print('Error occurred: $error');
        // Optionally show an alert or snackbar to the user
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                // Handle login logic here
                String username = usernameController.text;
                String password = passwordController.text;
                print('Username: $username, Password: $password');

                await _authenticate(username, password);

              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                NavigateToSignUpPage(context);
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
