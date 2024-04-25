import 'package:acter_project/public.dart';
import 'package:acter_project/server/achivement.dart';
import 'package:acter_project/server/chapter_manager.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:acter_project/server/server.dart';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const LoaderOverlay(
        child: ServerMain(),
      ),
    );
  }
}

class ServerMain extends StatefulWidget {
  const ServerMain({super.key});

  @override
  State<ServerMain> createState() => _ServerMainState();
}

class _ServerMainState extends State<ServerMain> {
  final Server server = Server();
  final ChapterManager chapterManger = ChapterManager();
  final AchivementDB achivementDB = AchivementDB();

  @override
  void initState() {
    context.loaderOverlay.show();

    server.init();
    server.addMessageListener(chapterManger);
    server.addMessageWriter(chapterManger);

    achivementDB.loadData().then((e) {
      context.loaderOverlay.hide();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  var (isSkipExisted, isActionExisted) =
                      chapterManger.changeToNextChapter(achivementDB);
                  server.broadcastMessage(
                      messageType: isSkipExisted
                          ? MessageType.activateSkipButton
                          : MessageType.disableSkipButton);
                  server.broadcastMessage(
                      messageType: isActionExisted
                          ? MessageType.activateActionButton
                          : MessageType.disableActionButton);
                },
                child: const Text('next chapter')),
            ElevatedButton(
                onPressed: () async {
                  server.broadcastMessage(
                      messageType: MessageType.onTheaterStarted);
                },
                child: const Text('Start theater')),
            ElevatedButton(
                onPressed: () async {
                  server.broadcastMessage(
                      messageType: MessageType.onAchivement,object: AchivementData(1, 0, 1, Condition.skip, 'name', '', ''));
                },
                child: const Text('achivement test'))
          ],
        ),
      ),
    );
  }
}
