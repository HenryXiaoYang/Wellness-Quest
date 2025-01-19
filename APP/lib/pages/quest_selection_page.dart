import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/shared_preferences_service.dart';
import '../widgets/quest_display_card.dart';

class QuestSelectionPage extends StatefulWidget {
  const QuestSelectionPage({super.key});

  @override
  State<StatefulWidget> createState() => QuestSelectionPageState();
}

class QuestSelectionPageState extends State<QuestSelectionPage> {
  late SharedPreferencesService pref;
  List<dynamic> quests = []; // Store quests here
  bool isLoading = true; // Loading state

  Future<void> _initializePreferences() async {
    pref = await SharedPreferencesService.getInstance();
    await fetchQuests("nutrition"); // Fetch quests after initializing preferences
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> fetchQuests(String questType) async {
    final String baseUrl = 'http://115.159.88.178:1111';
    final String endpoint = '/quests/$questType/get';
    String token = pref.getToken();
    final Uri url = Uri.parse('$baseUrl$endpoint');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse the JSON response
        var data = json.decode(response.body);
        // Check if the response contains a list of quests
        if (data['quests'] != null && data['quests'] is List) {
          setState(() {
            quests = data['quests']; // Store the fetched quests
            isLoading = false; // Update loading state
          });
        } else {
          print('No quests found or data is not in expected format.');
          setState(() {
            isLoading = false; // Update loading state even if no quests found
          });
        }
        print('Response data: $data');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select the quests for today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Quest Card
          Expanded(
            child: ListView.builder(
              itemCount: quests.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quests[index]['type'], // Adjust based on your data structure
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          quests[index]['name'], // Adjust based on your data structure
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          quests[index]['description'], // Adjust based on your data structure
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Cross Sign Button
                            ElevatedButton(
                              onPressed: () {
                                //delete
                                print('Cross Sign Pressed');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: const CircleBorder(),
                              ),
                              child: const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Icon(Icons.close,color: Colors.white)
                              ),
                            ),
                            const SizedBox(width: 20.0),

                            // Check Sign Button
                            ElevatedButton(
                              onPressed: () {
                                //accept & store
                                // Handle check action
                                print('Check Sign Pressed');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: const CircleBorder(),
                              ),
                              child: const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Icon(Icons.check,color: Colors.white)
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
