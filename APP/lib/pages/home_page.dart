import 'package:flutter/material.dart';
import 'package:wellness_quest/pages/quest_selection_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/requests.dart';
import '../utils/structures.dart';
import '../utils/shared_preferences_service.dart';
import '../widgets/quest_display_card.dart';
import 'leader_board.dart';
import '../utils/config_service.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late SharedPreferencesService pref;
  late ProfileBasic profile;
  String fullName = '';
  int completedQuests = 0;
  int level = 0;
  int points = 0;
  final QuestRequest qr = QuestRequest();
  bool showCelebration = false;
  List<dynamic> quests = [];
  bool isLoading = true;
  int questCnt = 0;
  List<Widget> widgets = [];
  bool isProfileLoading = true;

  Future<void> fetchAcceptedQuests() async {
    final config = await ConfigService.getInstance();
    final String url = '${config.apiUrl}/users/accepted';
    String token = pref.getToken();

    Future<List<QuestBasic>> doFetch() async {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['quests'] != null) {
          Map<String, dynamic> questsMap = data['quests'];
          List<QuestBasic> allQuests = [];
          
          final questTypes = ['nutrition', 'exercise', 'rest'];
          for (var type in questTypes) {
            if (questsMap.containsKey(type) && questsMap[type] is List) {
              List<QuestBasic> typeQuests = (questsMap[type] as List)
                  .map((questJson) => QuestBasic.fromJson(questJson))
                  .toList();
              allQuests.addAll(typeQuests);
            }
          }
          return allQuests;
        }
      }
      return [];
    }

    try {
      List<QuestBasic> allQuests = await doFetch();
      
      if (mounted) {
        setState(() {
          quests = allQuests;
          questCnt = allQuests.length;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _initializePreferences() async {
    pref = await SharedPreferencesService.getInstance();
    await Future.wait([
      fetchProfiles(),     // Wait for profile
      fetchAcceptedQuests() // Wait for quests
    ]);
    
    if (mounted) {
      setState(() {
        isProfileLoading = false;
        isLoading = false;
      });
    }
  }

  Future<void> fetchProfiles() async {
    try {
      profile = (await qr.profileQuest())!;
      if (mounted) {
        setState(() {
          fullName = profile.full_name;
          completedQuests = profile.completed_quests;
          level = profile.level;
          points = profile.points;
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    return hour < 12
        ? 'Good morning, $fullName.\n$completedQuests quests completed!'
        : 'Good afternoon, $fullName.\n$completedQuests quests completed!  ';
  }

  String _getAccount() {
    return 'Your are currently level $level and you have $points points.';
  }

  String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : ''
    ).join(' ');
  }

  @override
  void initState() {
    super.initState();
    // Delay the observer registration to ensure framework is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(this);
    });
    _initializePreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void NavigateToQuestSelectionPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const QuestSelectionPage()),
          (route) => false,
    );
  }

  Future<void> refreshAfterQuestCompletion() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      showCelebration = true; // Show celebration
    });
    
    try {
      await fetchProfiles();
      await fetchAcceptedQuests();
      
      // Hide celebration after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showCelebration = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          showCelebration = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Color.fromRGBO(3, 218, 198, 1);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isProfileLoading || isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: themeColor,
                ),
              )
            else
              SafeArea(
                bottom: false,  // Don't add safe area padding at bottom
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 140.0),  // Increased bottom padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeColor.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: 24.0, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  // New Level and Points visualization
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: themeColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Level $level',
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight: FontWeight.bold,
                                                      color: themeColor,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.stars,
                                                    color: themeColor,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              LinearProgressIndicator(
                                                value: (completedQuests % 5) / 5, // 5 tasks per level
                                                backgroundColor: Colors.white,
                                                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                                minHeight: 8,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                '$points points',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.0),
                            if (questCnt > 0) ...[
                              Text(
                                "Today's quests:",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              ...quests.map((quest) => Padding(
                                padding: EdgeInsets.only(bottom: 16.0),
                                child: QuestCard(
                                  topic: quest.type,
                                  title: quest.name,
                                  content: quest.description,
                                  quest_id: quest.quest_id.toString(),
                                  onComplete: () async {
                                    print('Attempting to complete quest: ${quest.quest_id} of type: ${quest.type}');
                                    await refreshAfterQuestCompletion();  // Use the new refresh method
                                  },
                                ),
                              )).toList(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(  // Changed Container to Padding
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      if (questCnt < 3)
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              NavigateToQuestSelectionPage(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Select More Quests',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LeaderboardPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: themeColor, width: 2),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'View Leaderboard',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Add celebration overlay
            if (showCelebration)
              CelebrationOverlay(),
          ],
        ),
      ),
    );
  }
}

class CelebrationOverlay extends StatefulWidget {
  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> particles = [];
  final Random random = Random();
  late Size screenSize;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.7, 1.0, curve: Curves.easeOut), // Start fading at 70% of animation
      ),
    );

    _controller.forward(); // Play animation once

    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenSize = MediaQuery.of(context).size;
      for (int i = 0; i < 50; i++) {
        particles.add(Particle(random, screenSize));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: fadeAnimation,
            child: CustomPaint(
              size: MediaQuery.of(context).size,
              painter: ParticlePainter(
                particles, 
                _controller.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late Color color;
  late double speed;
  late double size;
  final Size screenSize;
  late double opacity;

  Particle(Random random, this.screenSize) {
    reset(random);
    y = screenSize.height + random.nextDouble() * 100;
    opacity = 1.0;
  }

  void reset(Random random) {
    x = random.nextDouble() * screenSize.width;
    y = screenSize.height + random.nextDouble() * 100;
    color = Colors.primaries[random.nextInt(Colors.primaries.length)]
        .withOpacity(0.6);
    speed = 2 + random.nextDouble() * 4;
    size = 5 + random.nextDouble() * 10;
    opacity = 1.0;
  }

  void update(double progress) {
    y -= speed;
    // Gradually reduce opacity as particles move up
    if (y < screenSize.height * 0.3) { // Start fading when particle reaches top 30% of screen
      opacity = (y / (screenSize.height * 0.3)).clamp(0.0, 1.0);
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(progress);
      
      if (particle.y < -50) {
        particle.reset(Random());
      }

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
