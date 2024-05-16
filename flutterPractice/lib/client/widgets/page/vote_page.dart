import 'package:acter_project/client/Services/archive.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:acter_project/client/widgets/widget/notification.dart';
import 'package:acter_project/screen/widget/achivement_notification.dart';
import 'package:theater_publics/public.dart';
import 'package:theater_publics/vote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/corner.dart';
import '../widget/message_button.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage>
    with AutomaticKeepAliveClientMixin<VotePage>, TickerProviderStateMixin {
  bool bIsActionEnabled = false;
  late Archive archive;
  late Client client;
  int achivementId = 0;
  bool bIsAchived = false;
  ButtonStates buttonState = ButtonStates(false, false);

  late Size notificationDest;
  late AchivementNotificator notificator;
  late AchivementDataManger achivementDataManger;
  List<NotificationWidget> notificators = [];

  int count = 0;

  void onNotiFadeOut(NotificationWidget noti) {
    setState(() {
      notificators.remove(noti);
    });
  }

  @override
  void initState() {
    super.initState();
    client = context.read<Client>();
    client.addMessageListener((message) {
      switch (message.messageType) {
        case MessageType.onAchivement:
          {
            achivementId = int.parse(String.fromCharCodes(message.datas));

            var data = achivementDataManger.getData(achivementId);
            if(data == null) {
              print('$achivementId : 존재하지 않는 업적 ID');
              return; // 업적 오류 데이터 검출
            }

            var image = achivementDataManger.getImage(achivementId);

            notificator
                .showNotification(
                    image.image,
                    data.name,
                    const Duration(seconds: 3),
                    notificationDest / 2,
                    const Duration(microseconds: 250))
                .then((value) => setState(() {}));

            archive.addAchivement(achivementId);

            setState(() {
              notificators.add(NotificationWidget(
                  image: image, text: data.name, onFadeOut: onNotiFadeOut));
            });
          }
          break;
        default:
      }
    });

    notificator = AchivementNotificator(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notificationDest = MediaQuery.of(context).size;
    });

    achivementDataManger = context.read<AchivementDataManger>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    archive = Provider.of<Archive>(context);

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [const Corner(),..._pageBuilder()],
      ),
    );
  }

  List<Widget> _pageBuilder() {
    final List<Widget> widgets = [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                children: [...notificators],
              ),
            ),
            const SizedBox(
              width: 20,
              height: 20,
            ),
            MessageButtton(
              client,
              VoteType.skip,
            ),
            const SizedBox(
              width: 20,
              height: 20,
            ),
            MessageButtton(
              client,
              VoteType.action,
            ),
          ],
        ),
      )
    ];

    return widgets;
  }

  @override
  bool get wantKeepAlive => true;
}
