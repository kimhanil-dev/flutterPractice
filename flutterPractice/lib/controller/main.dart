import 'package:acter_project/controller/commnuicator.dart';
import 'package:acter_project/screen/event_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:theater_publics/public.dart';
import 'package:theater_publics/achivement.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:loader_overlay/loader_overlay.dart';

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
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            side: MaterialStateProperty.all<BorderSide>(
              BorderSide(
                color: color.primary,
              ),
            ),
          ),
        ),
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
  late Communicator_controller controller;
  AchivementDB achivementDB = AchivementDB();
  bool bIsInited = false;

  @override
  void initState() {
    context.loaderOverlay.show();

    Future<void>.microtask(() async {
      var dotEnv = DotEnv();
      await dotEnv.load(fileName: 'assets/.env');
      await achivementDB.loadData(dotEnv.env['GSHEETS_CREDENTIALS']!);

      controller = Communicator_controller(achivementDB, refresh);

      var config = await GlobalConfiguration().loadFromAsset('config.json');
      controller.connect(config.getValue<String>('server-ip'),
          config.getValue<int>('server-port'));

      context.loaderOverlay.hide();

      bIsInited = true;
    });

    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!bIsInited) {
      return const Scaffold();
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      '연극 재시작',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    content: const Text('정말로 다시 시작하시겠습니까?'),
                    actions: [
                      OutlinedButton(
                          onPressed: () {
                            controller
                                .sendMessage(MessageType.requestRestartTheater);
                            Navigator.of(context).pop();
                          },
                          child: const Text('예')),
                      OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('아니오'))
                    ],
                  );
                });
          },
          mini: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.black,
          child: const Icon(Icons.restart_alt),
        ),
        backgroundColor: Colors.black,
        body: Container(
          padding: const EdgeInsets.all(10),
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
    final title = Align(
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );

    List<Widget> rowChildren = [];
    for (var e in widgets) {
      rowChildren.add(Expanded(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: e,
      )));
    }
    final body =
        Row(mainAxisAlignment: MainAxisAlignment.center, children: rowChildren);

    var column = Container(
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: Theme.of(context).colorScheme.inversePrimary))),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          title,
          const Gap(10, crossAxisExtent: 10),
          body,
          const Gap(10, crossAxisExtent: 10)
        ],
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
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '관객 상태',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text('관객 수 : ${controller.players.length}'),
              Text('스킵 투표: ${controller.skipVoteCount}'),
              Text('액션 투표: ${controller.actionVoteCount}'),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Text('ID')),
                  Expanded(child: Text('Ping')),
                  Expanded(child: Text('Skip')),
                  Expanded(child: Text('Action'))
                ],
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: controller.players.length,
                    itemBuilder: (buildContext, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Text('${controller.players[index].id}')),
                          Expanded(
                              child: Text('${controller.players[index].ping}')),
                          Expanded(
                              child: Text(
                                  '${controller.players[index].isSkipVoted}')),
                          Expanded(
                              child: Text(
                                  '${controller.players[index].isActionVoted}'))
                        ],
                      );
                    }),
              )
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
    return Column(
      children: [
        Text(
          '챕터 정보',
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('- 현재 챕터 : ${controller.currentChapter}'),
                    const Text('- 업적'),
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
                        '스킵',
                        (controller.skipMajority * controller.players.length)
                            .round(),
                        controller.skipVoteCount),
                    makeProgressBar(
                        '액션',
                        (controller.actionMajority * controller.players.length)
                            .round(),
                        controller.actionVoteCount),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> getChapterAchivementsText() {
    final List<Text> result = [];
    final achivements = controller.curChapterAchivs;
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
              '$title 진행도',
              textAlign: TextAlign.left,
            )),
        Container(
            decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary)),
            child: LinearProgressIndicator(
              value: max == 0 ? 1 : current / max,
              backgroundColor: Colors.black,
              borderRadius: const BorderRadius.all(Radius.zero),
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
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '명령',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
          ),
          makeInterfaceWidget('챕터', [
            OutlinedButton(
                onPressed: () {
                  controller.sendMessage(MessageType.requestStartThater);
                },
                child: const Text('공연 시작')),
            OutlinedButton(
                onPressed: () {
                  controller.sendMessage(MessageType.requestNextChapter);
                  controller.skipVoteCount = 0;
                  controller.actionVoteCount = 0;
                  _refresh();
                },
                child: const Text('다음 챕터')),
          ]),
          makeInterfaceWidget('업적', [
            OutlinedButton(
                onPressed: () {
                  controller.sendMessage(
                      MessageType.requestBroadcastSequenceAchivement);
                  _refresh();
                },
                child: const Text('행동 업적 완료')),
            Text(
              '현재 행동 업적 : ${controller.getCurSequenceAchiveName()}',
              textAlign: TextAlign.center,
            )
          ]),
          makeInterfaceWidget('화면', [
            OutlinedButton(onPressed: () {}, child: const Text('화면 전환')),
            SizedBox(
              width: 500,
              height: 300,
              child: ListView.builder(
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    return ElevatedButton(
                      onPressed: () {
                        controller.sendMessage(MessageType.screenMessage,
                            data:
                                ScreenMessage(MessageType.nextSFX));
                      },
                      child: Row(children: [
                        const Text('이름'),
                        Image.asset(
                          'assets/images/bg/bg_1.jpg',
                          width: 100,
                          height: 50,
                        ),
                      ]),
                    );
                  }),
            ),
          ]),
        ],
      ),
    );
  }

  void _refresh() {
    setState(() {});
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: Column(
  //         children: [
  //           ElevatedButton(
  //               onPressed: () {
  //                 setState(() {});
  //                 var (isSkipExisted, isActionExisted) =
  //                     chapterManager.changeToNextChapter(achivementDB);
  //                 server.broadcastMessage(
  //                     messageType: isSkipExisted
  //                         ? MessageType.activateSkipButton
  //                         : MessageType.disableSkipButton);
  //                 server.broadcastMessage(
  //                     messageType: isActionExisted
  //                         ? MessageType.activateActionButton
  //                         : MessageType.disableActionButton);
  //               },
  //               child: const Text('next chapter')),
  //           ElevatedButton(
  //               onPressed: () async {
  //                 server.broadcastMessage(
  //                     messageType: MessageType.onTheaterStarted);
  //               },
  //               child: const Text('Start theater')),
  //           ElevatedButton(
  //               onPressed: () async {
  //                 server.broadcastMessage(
  //                     messageType: MessageType.onAchivement,
  //                     object: AchivementData(
  //                         1, 0, 1, Condition.skip, 'name', '', ''));
  //               },
  //               child: const Text('achivement test')),
  //           Expanded(
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 ElevatedButton(
  //                     onPressed: () {
  //                       chapterManager.boradcastSequenceAchivement();
  //                     },
  //                     child: const Text('SequenceAchivement')),
  //                 Expanded(
  //                   child: ListView.builder(
  //                     itemCount: chapterManager.getSequences().length,
  //                     itemBuilder: (context, index) {
  //                       return Text(chapterManager.getSequences()[index]);
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
