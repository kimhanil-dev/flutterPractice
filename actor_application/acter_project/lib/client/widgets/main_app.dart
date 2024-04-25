import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'start_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  @override
  void initState() {
    super.initState();
    context.read<AchivementDataManger>().loadDatas();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const Scaffold(
        body: Center(
          child: StartPage(),
        ),
      ),
    );
  }
}
