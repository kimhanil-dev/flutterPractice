import 'package:acter_project/client/Services/archive.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:acter_project/public.dart';
import 'package:acter_project/server/achivement.dart';
import 'package:acter_project/server/vote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'message_button.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage>
    with AutomaticKeepAliveClientMixin<SelectPage> {
  bool bIsActionEnabled = false;
  late Archive archive;
  late Client client;
  int achivementId = 0;
  bool bIsAchived = false;

  @override
  void initState() {
    super.initState();
    client = context.read<Client>();
    client.addMessageListener((message) {
      switch (message.messageType) {
        case MessageType.activateActionButton:
          {
            setState(() {
              bIsActionEnabled = true;
            });
          }
          break;
        case MessageType.onAchivement:
          {
            achivementId = int.parse(String.fromCharCodes(message.datas));
            archive.addAchivement(achivementId);
            setState(() {
              bIsAchived = true;
            });

            Future<void>.delayed(const Duration(seconds: 3))
                .then((value) => setState(() {
                      bIsAchived = false;
                    }));
          }
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    archive = Provider.of<Archive>(context);

    return Scaffold(
      body: Stack(
        children: _pageBuilder(),
      ),
    );
  }

  List<Widget> _pageBuilder() {
    final achivementDataManger = Provider.of<AchivementDataManger>(context);

    final List<Widget> widgets = [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MessageButtton(client, VoteType.skip),
            const SizedBox(
              width: 20,
              height: 20,
            ),
            MessageButtton(client, VoteType.action),
          ],
        ),
      )
    ];

    if (bIsAchived) {
      widgets.add(SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 100,
            height: 300,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 4.0)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                achivementDataManger.getImage(achivementId)!,
                Text(achivementDataManger.getData(achivementId).name),
              ],
            ),
          ),
        ),
      ));
    }

    return widgets;
  }

  @override
  bool get wantKeepAlive => true;
}
