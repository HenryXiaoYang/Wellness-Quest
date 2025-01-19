import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/preference_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  Future<bool> registerAccount({
    required String username,
    required String password,
    required String fullName,
    required int age,
    required String gender,
  }) async {
    final config = await ConfigService.getInstance();
    final String apiUrl = '${config.apiUrl}/auth/register';

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      "username": username,
      "password": password,
      "full_name": fullName,
      "age": age,
      "gender": gender,
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json', // Set the content type
        },
        body: json.encode(requestBody), // Encode the request body to JSON
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Registration successful
        return true;
      } else {
        // Handle error response
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final config = await ConfigService.getInstance();
    final String apiUrl = '${config.apiUrl}/auth/login';

    // Prepare the body in x-www-form-urlencoded format
    final Map<String, String> data = {
      'username': username,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: data, // Use the Map directly as the body
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Update to match the correct token key from login response
        responseData['token'] = responseData['access_token'];
        return responseData;
      }
      return null;
    } catch (e) {
      print('Login Exception: $e');
      return null;
    }
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'male'; // Default gender

  void _register() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String fullName = _fullNameController.text;
    final int age = int.tryParse(_ageController.text) ?? 0;

    final bool success = await registerAccount(
      username: username,
      password: password,
      fullName: fullName,
      age: age,
      gender: _gender,
    );

    if (success) {
      // Attempt to login immediately after successful registration
      final loginResponse = await loginUser(username, password);
      if (loginResponse != null) {
        // Store the token using the correct key
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', loginResponse['access_token']);
        
        // Navigate to preference page instead of home
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PreferencePage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful but auto-login failed. Please login manually.')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _gender,
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue!;
                });
              },
              items: <String>['male', 'female', 'non-binary']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
