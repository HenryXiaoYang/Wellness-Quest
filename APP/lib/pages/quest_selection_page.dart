import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/shared_preferences_service.dart';
import '../widgets/quest_display_card.dart';
import 'home_page.dart';

class QuestSelectionPage extends StatefulWidget {
  const QuestSelectionPage({super.key});

  @override
  State<StatefulWidget> createState() => QuestSelectionPageState();
}

class QuestSelectionPageState extends State<QuestSelectionPage> {
  late SharedPreferencesService pref;
  List<dynamic> quests = [];
  int questCnt=0;
  bool isLoading = true; // Loading state
  bool nutritionAcc = false;
  bool exerciseAcc = false;
  bool restAcc = false;
  void NavigateToHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
    );
  }
  Color _color(){
    if(!nutritionAcc){
      return Color.fromRGBO(131,197,255,1);;
    } else if (!exerciseAcc){
      return Color.fromRGBO(255,158,191,1);;
    } else if (!restAcc){
      return Color.fromRGBO(218,193,103,1);;
    } else {
      return Color.fromRGBO(255,255,255,1);
    }
  }
  String _type() {
    if(!nutritionAcc){
      return "nutrition";
    } else if (!exerciseAcc){
      return "exercise";
    } else if (!restAcc){
      return "rest";
    } else {
      return "none";
    }
  }
  void _change(){
    questCnt++;
    if(questCnt==3) NavigateToHomePage(context);
    if(!nutritionAcc){
      nutritionAcc=true;
    } else if(!exerciseAcc){
      exerciseAcc=true;
    } else if(!restAcc){
      restAcc=true;
    }
  }
  Future<void> deleteQuest(String questId) async {
    final String url = 'http://115.159.88.178:1111/quests/$questId/delete';
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
        // Successfully deleted the quest
        print('Quest deleted successfully: ${response.body}');
      } else {
        // Handle error response
        print('Failed to delete quest: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error occurred: $e');
    }
  }
  Future<void> _initializePreferences() async {
    pref = await SharedPreferencesService.getInstance();
    await fetchQuests(_type());// Fetch quests after initializing preferences
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }
  Future<void> acceptQuest(String questId) async {
    final String url = 'http://115.159.88.178:1111/quests/$questId/accept';
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
        // Successfully accepted the quest
        print('Quest accepted successfully: ${response.body}');
      } else {
        // Handle error response
        print('Failed to accept quest: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error occurred: $e');
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select the quests for today---$questCnt/3',
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
          Container(
            height: MediaQuery.sizeOf(context).height*0.8,
                child: Card(
                  color: _color(),
                  margin: const EdgeInsets.all(24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // This will push content to the top and bottom
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          quests[0]['type'], // Adjust based on your data structure
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          quests[0]['name'], // Adjust based on your data structure
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          quests[0]['description'], // Adjust based on your data structure
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20.0), // Optional spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Cross Sign Button
                            ElevatedButton(
                              onPressed: () async {
                                await deleteQuest(quests[0]['quest_id'].toString());
                                await fetchQuests(_type());
                                setState(() {});
                                print('Cross Sign Pressed');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: const CircleBorder(),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 20.0),

                            // Check Sign Button
                            ElevatedButton(
                              onPressed: () async {
                                await acceptQuest(quests[0]['quest_id'].toString());
                                _change();
                                await fetchQuests(_type());
                                setState(() {});
                                print('Check Sign Pressed');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: const CircleBorder(),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(Icons.check, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
          ),
        ],
      ),
    );
  }
}
