import 'package:flutter/material.dart';
import 'package:wellness_quest/pages/preference_page.dart';
import 'package:wellness_quest/pages/sign_up.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/shared_preferences_service.dart';
import '../utils/config_service.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late SharedPreferencesService pref;
  bool isLoading = false;
  bool _obscurePassword = true;

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
    final config = await ConfigService.getInstance();
    final String url = '${config.apiUrl}/auth/login';

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
    final themeColor = Color.fromRGBO(3, 218, 198, 1);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 40),
                              Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Sign in to continue your wellness journey',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(height: 48),
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
                                  controller: usernameController,
                                  decoration: InputDecoration(
                                    hintText: 'Username',
                                    prefixIcon: Icon(Icons.person_outline, color: themeColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.all(20),
                                  ),
                                  keyboardType: TextInputType.name,
                                ),
                              ),
                              SizedBox(height: 16),
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
                                  controller: passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outline, color: themeColor),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: themeColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.all(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : () async {
                                    setState(() => isLoading = true);
                                    await _authenticate(
                                      usernameController.text,
                                      passwordController.text,
                                    );
                                    setState(() => isLoading = false);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => NavigateToSignUpPage(),
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: themeColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
