import 'package:acter_project/client/client.dart';
import 'package:acter_project/client/main.dart';
import 'package:acter_project/public.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    widget.client.addMessageListener((message) {
      switch (MessageType.getMessage(message)) {
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
              achivementText = message;
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
            ButtonWithMessage(widget.client, false),
            const SizedBox(
              width: 20,
              height: 20,
            ),
            ButtonWithMessage(widget.client, true),
          ],
        ),
      ),
    );
  }
}
