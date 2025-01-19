import 'package:flutter/material.dart';

import 'log_in.dart';

class SplashPage extends StatefulWidget{
  @override
  State createState()=>_State();

}
class _State extends State<SplashPage>{
  @override
  Widget build(BuildContext context) {
    void NavigateToLogInPage(context) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LogInPage()),
              (route) => false
      );
    }
    // final ttsmanager = TtsManager();
    // ttsmanager.speak("Splash page");

    Future.delayed(
      const Duration(seconds: 3),
          (){NavigateToLogInPage(context);},
      // (){Navigator.pushAndRemoveUntil(context, newRoute, predicate)}
    );

    return Scaffold( //p

      backgroundColor: Color.fromRGBO(3, 218, 198, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(width: 10),
              const Flexible(
                child: Text(
                  'Wellness Quest',
                  style: TextStyle(fontSize: 35, color: Colors.white),
                ),
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