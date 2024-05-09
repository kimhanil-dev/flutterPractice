import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/screen/service/screen_effect_manager.dart';
import 'package:acter_project/screen/service/screen_message.dart';
import 'package:acter_project/screen/widget/achivement_notification.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:theater_publics/public.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(background: Colors.black)),
      home: const LoaderOverlay(child: ScreenPage()),
      //TestWidget(),
    );
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
  final List<Widget> dynamicWidgets = [];
  Image? image = Image.asset('assets/images/bg/bg_0.jpg');

  late AchivementNotificator notificator = AchivementNotificator(this);
  bool bIsLoading = true;

  @override
  void initState() {
    super.initState();

    context.loaderOverlay.show();
    screenEffectManager = ScreenEffectManager(() {
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
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image(
              image: screenEffectManager.backgroundImage.image,
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
            // uis
            ...screenEffectManager.getUIs(),
            // notifications
            Stack(
                alignment: Alignment.center,
                children: notificator.getAllNotiWidgets()),
            SpriteWidget(screenEffectManager.rootNode),
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
        notificator
            .showNotification(
                achivementDataManager.getImage(achivementId).image,
                achivementData.name,
                const Duration(seconds: 1, milliseconds: 500),
                MediaQuery.of(context).size / 2,
                const Duration(milliseconds: 250))
            .then((value) => setState(() {}));
        break;
      default:
    }
  }
}
