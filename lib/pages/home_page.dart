import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  // final List<Widget> _pages = [
  //   ToolboxPage(),
  //   SelectionPage(),
  //   SettingsPage()
  // ];
  // int _selectedIndex = 1;
  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }
  // Widget playButton(){
  //   return FilledButton(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.blueAccent,
  //     ),
  //     onPressed: () {
  //       ttsmanager.stop().then((_) {ttsmanager.speak(_appbar_info[_selectedIndex]);} );
  //     },
  //     child: Text(
  //         "Info",
  //         style: TextStyle(
  //           fontSize: 28,
  //         )
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(210,224,235,1),
        // title: Stack(
        //   children: [
        //     // Text(
        //     //     _appbar_text[_selectedIndex],
        //     //     style:TextStyle(
        //     //         fontSize:40,
        //     //         fontWeight: FontWeight.bold,
        //     //         color:Colors.blue
        //     //     )
        //     // ),
        //     // Align(
        //     //   alignment: Alignment.centerRight,
        //     //   child: SizedBox(
        //     //       width: MediaQuery.sizeOf(context).width/2.5,
        //     //       height: MediaQuery.sizeOf(context).height/16,
        //     //       child:playButton()
        //     //   ),
        //     // )
        //   ],
        // ),
      ),
      // body: _pages[_selectedIndex],
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.all_inbox),
      //       label: 'Toolbox',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.video_camera_back),
      //       label: 'AI Navigation',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.blue[800],
      //   onTap: _onItemTapped,
      //   iconSize: 45,
      //   selectedFontSize: 19,
      //   unselectedFontSize: 16,
      // ),
    );
  }
}