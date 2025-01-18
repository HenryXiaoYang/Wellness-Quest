import 'package:flutter/material.dart';
import 'package:wellness_quest/pages/preference_page.dart';

class SplashPage extends StatefulWidget{
  @override
  State createState()=>_State();

}
class _State extends State<SplashPage>{
  @override
  Widget build(BuildContext context) {
    void NavigateToPreferencePage(context) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PreferencePage()),
              (route) => false
      );
    }
    // final ttsmanager = TtsManager();
    // ttsmanager.speak("Splash page");

    Future.delayed(
      const Duration(seconds: 3),
          (){NavigateToPreferencePage(context);},
      // (){Navigator.pushAndRemoveUntil(context, newRoute, predicate)}
    );

    return Scaffold( //p3
      backgroundColor: Color.fromRGBO(3, 218, 198, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon.png', // Replace with your image path
                width: 120,
                height: 120,
              ),
              // const SizedBox(width: 20), // Add spacing between image and text
              const Text(
                'Wellness Quest',
                style: TextStyle(fontSize: 35,color: Colors.white),
              ),
            ],
          ),
          const Text(
              'For your healthcare',
              style: TextStyle(fontSize:20,color:Colors.white)
          )
        ],
      ),
    );
  }
}