import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/shared_preferences_service.dart';
import '../widgets/quest_display_card.dart';
import 'home_page.dart';
import '../utils/config_service.dart';

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
  bool isButtonLoading = false; // Add this state variable at the class level
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
    final config = await ConfigService.getInstance();
    final String url = '${config.apiUrl}/quests/$questId/delete';
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
    final config = await ConfigService.getInstance();
    final String url = '${config.apiUrl}/quests/$questId/accept';
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
    final config = await ConfigService.getInstance();
    final String url = '${config.apiUrl}/quests/$questType/get';
    String token = pref.getToken();
    final Uri uri = Uri.parse(url);
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(uri, headers: headers);

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
    final themeColor = Color.fromRGBO(3, 218, 198, 1);
    return Scaffold(
      body: Container(
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
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: themeColor))
            : SafeArea(
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Your Quests',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$questCnt of 3 quests selected',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: questCnt / 3,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ),
                    
                    // Quest Card
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Container(
                            key: ValueKey<String>(quests[0]['quest_id'].toString()),
                            width: double.infinity,
                            height: double.infinity,
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.0),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _getQuestTypeColors(),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                capitalizeWords(quests[0]['type']),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 24),
                                            Text(
                                              capitalizeWords(quests[0]['name']),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  quests[0]['description'],
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white.withOpacity(0.9),
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 32),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _buildActionButton(
                                            icon: Icons.close,
                                            color: Colors.white,
                                            backgroundColor: Colors.red.withOpacity(0.8),
                                            onPressed: isButtonLoading ? null : () async {
                                              setState(() => isButtonLoading = true);
                                              await deleteQuest(quests[0]['quest_id'].toString());
                                              await fetchQuests(_type());
                                              setState(() => isButtonLoading = false);
                                            },
                                          ),
                                          SizedBox(width: 32),
                                          _buildActionButton(
                                            icon: Icons.check,
                                            color: Colors.white,
                                            backgroundColor: Colors.green.withOpacity(0.8),
                                            onPressed: isButtonLoading ? null : () async {
                                              setState(() => isButtonLoading = true);
                                              await acceptQuest(quests[0]['quest_id'].toString());
                                              _change();
                                              await fetchQuests(_type());
                                              setState(() => isButtonLoading = false);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.all(24),
          shape: CircleBorder(),
          elevation: 0,
        ),
        child: isButtonLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: color,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, color: color, size: 32),
      ),
    );
  }

  List<Color> _getQuestTypeColors() {
    if (!nutritionAcc) {
      return [
        Color(0xFF64B5F6),
        Color(0xFF1E88E5),
      ];
    } else if (!exerciseAcc) {
      return [
        Color(0xFFFF80AB),
        Color(0xFFD81B60),
      ];
    } else if (!restAcc) {
      return [
        Color(0xFFFFD54F),
        Color(0xFFFFA000),
      ];
    } else {
      return [
        Colors.grey.shade300,
        Colors.grey.shade400,
      ];
    }
  }

  String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : ''
    ).join(' ');
  }
}
