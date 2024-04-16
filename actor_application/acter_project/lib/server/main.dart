import 'dart:io';

import 'package:acter_project/public.dart';
import 'package:acter_project/server/achivement.dart';
import 'package:acter_project/server/chapter_manager.dart';
import 'package:acter_project/server/vote.dart';
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
      home: LoaderOverlay(
        child: ServerMain(),
      ),
    );
  }
}

class ServerMain extends StatefulWidget {
  ServerMain({super.key});

  @override
  State<ServerMain> createState() => _ServerMainState();
}

class _ServerMainState extends State<ServerMain> {
  final Server server = Server();
  final ChapterManager chapterManger = ChapterManager();
  final AchivementDB achivementDB = AchivementDB();
  final Vote skipVoter = Vote();
  final Vote actionVoter = Vote();

  @override
  void initState() {
    context.loaderOverlay.show();

    server.init();

    achivementDB.loadData().then((e) {
      context.loaderOverlay.hide();
    });

    chapterManger.bindOnChapterStart((isSkipExisted, isActionExisted) {
      if (isSkipExisted) {
        skipVoter.startVote(
            voteType: VoteType.skip,
            majority: 1,
            voteDuration: const Duration(days: 1),
            onVoteEnded: onSkipVoteEnd);
      }
      if (isActionExisted) {
        actionVoter.startVote(
            voteType: VoteType.action,
            majority: 1,
            voteDuration: const Duration(minutes: 1),
            onVoteEnded: onActionVoteEnd);
      }
    });

    server.addMessageListener(skipVoter);
    server.addMessageListener(actionVoter);

    super.initState();
  }

  void onSkipVoteEnd(bool result, List<Socket> yayers, List<Socket> nayers) {
    for (var achivement in chapterManger.curChapterAchivements) {
      if (achivement.condition == Condition.skip) {
        server.multicastMessage(
            dests: yayers,
            msgType: MessageType.onAchivement,
            datas: achivement.id.toString().codeUnits);
      }
    }

    print('vote ended');
  }

  void onActionVoteEnd(bool result, List<Socket> yayers, List<Socket> nayers) {
    for (var achivement in chapterManger.curChapterAchivements) {
      if (achivement.condition == Condition.action) {
        if (achivement.condition == Condition.skip) {
          server.multicastMessage(
              dests: yayers,
              msgType: MessageType.onAchivement,
              datas: achivement.id.toString().codeUnits);
        }
      }
    }
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
                child: const Text('Start theater'))
          ],
        ),
      ),
    );
  }
}
