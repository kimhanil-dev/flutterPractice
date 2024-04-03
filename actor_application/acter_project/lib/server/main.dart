import 'package:acter_project/public.dart';
import 'package:flutter/material.dart';

import 'package:acter_project/server/server.dart';

void main() async {
  
  runApp(const MainApp());
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final Server server = Server();

  @override
  void initState() {
    // open connection
    server.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () async {
                      server.broadcastMessage(MessagePreset.start.name);
                  },
                  child: const Text('Start theater'))
            ],
          ),
        ),
      ),
    );
  }
}
