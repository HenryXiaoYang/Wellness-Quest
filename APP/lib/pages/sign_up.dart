import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'log_in.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'male';


  @override
  Widget build(BuildContext context) {
    void NavigateToLogInPage(context) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LogInPage()),
              (route) => false
      );
    }
    Future<void> _submitData() async {
      final data = {
        "username": _usernameController.text,
        "password": _passwordController.text,
        "full_name": _fullNameController.text,
        "age": int.parse(_ageController.text),
        "gender": _selectedGender,
      };

      const String url = 'https://127.0.0.1:8000';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(data),
        );

        if (response.statusCode == 200) {
          // Handle successful response
          print('Response data: ${response.body}');

          // Navigate to the next screen after successful signup
          NavigateToLogInPage(context);
        } else {
          // Handle error response
          print('Failed to sign up: ${response.body}');
        }
      } catch (error) {
        print('Error occurred: $error');
      }

      print('Sign-up data: $data'); // For demonstration purposes

      // Navigate to the next screen after successful signup
      //token
      NavigateToLogInPage(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a username' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a password' : null,
              ),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your full name' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 13) {
                    return 'Age must be at least 13';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'male',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                  const Text('Male'),
                  Radio<String>(
                    value: 'female',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                  const Text('Female'),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process the data
                    _submitData();
                  }
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}