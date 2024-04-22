import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'start_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LoaderOverlay(
        child: Scaffold(
          body: Center(
            child: StartPage(),
          ),
        ),
      ),
    );
  }
}
