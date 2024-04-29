
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw MaterialApp(home: ScreenPage(),);
  }
}

class ScreenPage extends StatefulWidget {  @override
  State<ScreenPage> createState() => _ScreenPageState();
}

class _ScreenPageState extends State<ScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWYpQ1rvhVh1-Er_sAh7jptqf8cGrvz0UC0EJCiz7KFwKWiQ0pujBu3SpQb3Lhq1uQl8s&usqp=CAU'),
    );
  }}
