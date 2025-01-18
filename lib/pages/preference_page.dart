import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencePage extends StatefulWidget{
  const PreferencePage({super.key});
  @override
  State<StatefulWidget> createState() => IntroPageState();
}

class Question {
  final String text;
  final List<String> options;
  Question({required this.text, required this.options});
}


class IntroPageState extends State<PreferencePage>{
  // void NavigateToHomePage(context) {
  //   Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (context) => const HomePage()),
  //           (route) => false
  //   );
  // }
  int index = 0;
  static const List<String> _title = [
    'Welcome!',
    'How often do you eat a balanced diet?',
    'How many days/week do you exercise?',
    'How satisfied are you with your sleep?',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(3, 218, 198, 1),
        body: Column(
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height*0.9,
              margin: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 30.0),
              child: Stack(
                  children:[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _title[index],
                            style:const TextStyle(fontSize: 35,fontWeight: FontWeight.bold,color:Colors.white)
                        ),
                        if(index==0) Text(
                            'Before we start, we would like to learn from you.'
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width:MediaQuery.sizeOf(context).width,
                        height:MediaQuery.sizeOf(context).height/7,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              index++;
                              // if(index==3)NavigateToHomePage(context);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                              'Next',
                              style:TextStyle(fontSize:30,color:Color.fromRGBO(3, 218, 198, 1),)
                          ),
                        ),
                      ),
                    )
                  ]
              ),
            ),
          ],
        )

    );
  }
}