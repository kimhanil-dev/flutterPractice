import 'package:acter_project/client/Services/archive.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:acter_project/screen/widget/achivement_notification.dart';
import 'package:theater_publics/public.dart';
import 'package:theater_publics/vote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'message_button.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage>
    with AutomaticKeepAliveClientMixin<SelectPage>, TickerProviderStateMixin {
  bool bIsActionEnabled = false;
  late Archive archive;
  late Client client;
  int achivementId = 0;
  bool bIsAchived = false;
  ButtonStates buttonState = ButtonStates(false, false);

  late Size notificationDest;
  late AchivementNotificator notificator;
  late AchivementDataManger achivementDataManger;

  @override
  void initState() {
    super.initState();
    client = context.read<Client>();
    client.addMessageListener((message) {
      switch (message.messageType) {
        case MessageType.onAchivement:
          {
            achivementId = int.parse(String.fromCharCodes(message.datas));

            var image = achivementDataManger.getImage(achivementId);
            var data = achivementDataManger.getData(achivementId);

            notificator
                .showNotification(
                    image.image,
                    data.name,
                    const Duration(seconds: 3),
                    notificationDest / 2,
                    const Duration(microseconds: 250))
                .then((value) => setState(() {}));

            archive.addAchivement(achivementId);
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
        children: _pageBuilder(),
      ),
    );
  }

  List<Widget> _pageBuilder() {
    final List<Widget> widgets = [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

    widgets.addAll(notificator.getAllNotiWidgets());
    return widgets;
  }

  @override
  bool get wantKeepAlive => true;
}
