import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import 'page/start_page.dart';

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
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 219, 163),
            primary: const Color.fromARGB(255, 255, 219, 163),
            background: const Color.fromARGB(255, 33, 30, 30))
      ),
      home: const LoaderOverlay(
        child: Scaffold(
          body: Center(
            child: DefaultTextStyle(
              style: TextStyle(color: Color.fromARGB(255,255,219,163)),
              child: StartPage()),
          ),
        ),
      ),
    );
  }
}
