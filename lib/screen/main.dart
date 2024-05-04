
import 'package:acter_project/screen/event_manager.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ScreenPage(),);
  }
}

class ScreenPage extends StatefulWidget {  @override
  State<ScreenPage> createState() => _ScreenPageState();
}

class _ScreenPageState extends State<ScreenPage> {
  EventManager eventManager = EventManager();
  Image? image = Image.asset('assets/images/bg/bg_0.jpg');

  @override
  void initState() {
    super.initState();
    eventManager.connect();
    eventManager.bindOnBackgroundChanged(onImageChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        getBackgroundImage(),
      ],),
    );
  }
  
  Widget getBackgroundImage() {
    return image!;
  }

  void onImageChanged(Image background) {
   image = background; 
  }
 }
