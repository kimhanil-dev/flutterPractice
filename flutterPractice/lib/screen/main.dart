import 'dart:ui';

import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/screen/service/screen_effect_manager.dart';
import 'package:acter_project/screen/service/screen_message.dart';
import 'package:acter_project/screen/widget/achivement_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:theater_publics/public.dart';

import 'service/data_manager.dart';

Future<FragmentShader> loadShader() async {
  FragmentProgram program =
      await FragmentProgram.fromAsset('assets/shaders/transition.frag');
  FragmentShader shader = program.fragmentShader();
  return shader;
}

void main() async {
  FragmentShader shader = await loadShader();
  Animate.restartOnHotReload = true;

  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => shader),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(background: Colors.black)),
      home: const LoaderOverlay(child: LoadingPage()),
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.loaderOverlay.show();
    DataManager dataManager = DataManager();
    dataManager.loadDatas().then((value) {
      context.loaderOverlay.hide();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (context) {
          return Provider(
              create: (_) => dataManager, child: const ScreenPage());
        },
      ), (route) => false);
    });

    return Container();
  }
}

class ScreenPage extends StatefulWidget {
  const ScreenPage({super.key});

  @override
  State<ScreenPage> createState() => _ScreenPageState();
}

class _ScreenPageState extends State<ScreenPage> with TickerProviderStateMixin {
  final Client client = Client(clientType: Who.screen);
  late ScreenEffectManager screenEffectManager;
  final AchivementDataManger achivementDataManager = AchivementDataManger();
  late AchivementNotificator notificator = AchivementNotificator(this);
  bool bIsLoading = true;

  @override
  void initState() {
    super.initState();

    context.loaderOverlay.show();
    screenEffectManager = ScreenEffectManager(context.read<DataManager>(), () {
      setState(() {});
    });

    // loading
    Future<void>.microtask(() async {
      List<Future<void>> tasks = [];

      // tasks.add(
      //     GlobalConfiguration().loadFromAsset('config.json').then((config) {
      //   client.connectToServer(config.getValue<String>('server-ip'),
      //       config.getValue<int>('server-port'), (p0) {});
      // }));

      tasks.add(achivementDataManager.loadDatas());

      tasks.add(screenEffectManager.loadScreenEffects());

      await Future.wait(tasks);
    }).then((value) {
      setState(() {
        bIsLoading = false;
        context.loaderOverlay.hide();
      });
    });
    // end loading

    client.addMessageListener(screenEffectManager.onMessage);
    client.addMessageListener(messageListener);

    // notification widget
  }

  @override
  Widget build(BuildContext context) {
    if (bIsLoading) {
      return Container();
    }

    return Scaffold(
      body: Container(
        height: 1080,
        width: 1920,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            screenEffectManager.getUI(context),
            SpriteWidget(screenEffectManager.rootNode),
            // notifications
            Stack(
                alignment: Alignment.center,
                children: notificator.getAllNotiWidgets()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          screenEffectManager
              .processScreenMessage(ScreenMessage(MessageType.nextSFX));
        },
      ),
    );
  }

  void messageListener(MessageData msgData) {
    switch (msgData.messageType) {
      case MessageType.onAchivement:
        var achivementId = int.parse(String.fromCharCodes(msgData.datas));
        var achivementData = achivementDataManager.getData(achivementId);
        if (achivementData != null) {
          notificator
              .showNotification(
                  achivementDataManager.getImage(achivementId).image,
                  achivementData.name,
                  const Duration(seconds: 1, milliseconds: 500),
                  MediaQuery.of(context).size / 2,
                  const Duration(milliseconds: 250))
              .then((value) => setState(() {}));
        }
        break;
      default:
    }
  }
}
