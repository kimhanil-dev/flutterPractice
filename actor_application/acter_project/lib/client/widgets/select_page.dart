import 'package:acter_project/client/Services/archive.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/public.dart';
import 'package:acter_project/server/vote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'button_with_message.dart';

class SelectPage extends StatefulWidget {
  const SelectPage(this.client, {super.key});
  final Client client;

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  bool bIsAchived = false;
  bool bIsActionEnabled = false;
  String achivementText = '업적';
  late Archive archive;

  @override
  void initState() {
    widget.client.addMessageListener((message) {
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
            setState(() {
              bIsAchived = true;
              achivementText = String.fromCharCodes(message.datas);
              archive.addAchivement(int.parse(String.fromCharCodes(message.datas)));
            });

            Future.delayed(const Duration(seconds: 2)).then((value) {
              setState(() {
                bIsAchived = false;
              });
            });
          }
          break;
        default:
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    archive = Provider.of<Archive>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            bIsAchived
                ? Card(child: Text('업적 : $achivementText'))
                : const SizedBox(
                    width: 0,
                    height: 0,
                  ),
            const SizedBox(width: 20, height: 20),
            MessageSendButton(widget.client, VoteType.skip),
            const SizedBox(
              width: 20,
              height: 20,
            ),
            MessageSendButton(widget.client, VoteType.action),
          ],
        ),
      ),
    );
  }
}
