import 'dart:io';

import 'package:acter_project/controller/commnuicator.dart';
import 'package:acter_project/public.dart';
import 'package:acter_project/server/achivement.dart';
import 'package:acter_project/server/play_manager.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:acter_project/server/server.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var color = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 0, 255, 0),
      background: Colors.black,
      primary: const Color.fromARGB(255, 0, 255, 0),
    );

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: color,
        textTheme: TextTheme(
            bodyMedium: TextStyle(
                color: color.primary, fontSize: 15, fontFamily: 'DOSMyungjo'),
            displaySmall: TextStyle(
                color: color.primary, fontSize: 15, fontFamily: 'DOSMyungjo'),
            displayLarge: TextStyle(
                color: color.primary, fontSize: 40, fontFamily: 'DOSMyungjo'),
            displayMedium: TextStyle(
                color: color.primary, fontSize: 30, fontFamily: 'DOSMyungjo')),
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
  final AchivementDB achivementDB = AchivementDB();
  late PlayManager chapterManager;
  late Communicator_server commnuicator;

  int skipVoteCount = 0;
  void onSkipVoteIncrease(Socket newVoter,int count) {
    setState(() {
      skipVoteCount = count;
    });
  }

  int actionVoteCount = 0;
  void onActionVoteIncrease(Socket newVoter,int count) {
    setState(() {
      actionVoteCount = count;
    });
  }

  @override
  void initState() {
    context.loaderOverlay.show();

    
    chapterManager = PlayManager();

    server.init();
    server.addMessageListener(chapterManager);
    server.addMessageWriter(chapterManager);

    achivementDB.loadData().then((e) {
      context.loaderOverlay.hide();
    });

    commnuicator = Communicator_server(server, chapterManager, achivementDB);
    server.addMessageListener(commnuicator);
    server.createPingStream(const Duration(seconds: 2)).listen((ping) {
     chapterManager.pingListener(ping);
     print('${ping.dest.address} : ${ping.millisec}');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      getChapterStateWidget(),
                      getInterfaceSateWidget(),
                    ],
                  ),
                ),
              ),
              getClientStateWidget()
            ],
          ),
        ));
  }

  Widget makeInterfaceWidget(String label, List<Widget> widgets) {
    final List<Widget> children = [];
    children.add(Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: Theme.of(context).textTheme.displayMedium,
      ),
    ));
    for (var element in widgets) {
      children.addAll([const SizedBox(height: 10), element]);
    }
    var column = Container(
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: Theme.of(context).colorScheme.inversePrimary))),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
    return column;
  }

  Widget getClientStateWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.inversePrimary)),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Client State',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text('Viwers : ${chapterManager.clients.length}'),
              Text('Skip : $skipVoteCount'),
              Text('Action : $actionVoteCount'),
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(child: Text('ID')),
                Expanded(child: Text('Ping')),
                Expanded(child: Text('Skip')),
                Expanded(child: Text('Action'))
              ])
            ],
          ),
        ),
      ),
    );
  }

  // Widget getClientsInfo() {
  //   final List<Widget> result = [];
  //   for (var e in chapterManager.clients) {
  //     var pingDelay = server.getPingDelay(e.address.address);
      
  //   }
  // }

  Widget getChapterStateWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapter State',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text('- Current Chapter : ${chapterManager.currentChaper}'),
                const Text('- Achivements'),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getChapterAchivementsText(),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                makeProgressBar(
                    'Skip', chapterManager.skipMajority, skipVoteCount),
                makeProgressBar(
                    'Action', chapterManager.actionMajority, actionVoteCount)
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> getChapterAchivementsText() {
    final List<Text> result = [];
    final achivements = chapterManager.curChapterAchives;
    for (var e in achivements) {
      result.add(Text('${e.condition.name} : ${e.name}'));
    }
    return result;
  }

  Widget makeProgressBar(String title, int max, int current) {
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$title Progress',
              textAlign: TextAlign.left,
            )),
        Container(
            decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(255, 0, 255, 0))),
            child: LinearProgressIndicator(
              value: max == 0 ? 1 : current / max  ,
              backgroundColor: Colors.black,
              borderRadius: BorderRadius.all(Radius.zero),
              minHeight: 15,
            )),
        Text('$current / $max')
      ],
    );
  }

  Widget getInterfaceSateWidget() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Interface',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ),
          makeInterfaceWidget('Chapter', [
            OutlinedButton(
                onPressed: () {
                  chapterManager.changeToNextChapter(achivementDB);
                  server.broadcastMessage(
                      messageType: MessageType.onTheaterStarted);
                  _refresh();
                },
                child: Text('Start Theater')),
            OutlinedButton(
                onPressed: () {
                  chapterManager.changeToNextChapter(achivementDB);
                  skipVoteCount = 0;
                  actionVoteCount = 0;
                  _refresh();
                },
                child: Text('Next Chapter')),
          ]),
          makeInterfaceWidget('Achivement', [
            OutlinedButton(
                onPressed: () {
                  chapterManager.boradcastSequenceAchivement();
                  _refresh();
                },
                child: const Text('Send Sequence Achivement')),
            Text('현재 Sequence : ${chapterManager.currentSequenceAchivement != null ? chapterManager.currentSequenceAchivement!.name : '없음'}')
          ]),
          makeInterfaceWidget('Chapter', [
            OutlinedButton(onPressed: () {}, child: Text('Change Scene')),
            OutlinedButton(onPressed: () {}, child: Text('Play Effect')),
            OutlinedButton(onPressed: () {}, child: Text('Play Sound')),
          ]),
        ],
      ),
    );
  }

  void _refresh() {
    setState(() {});
  }

  @override
  void dispose(){
    super.dispose();
    server.close();
  }
}