import 'package:acter_project/client/client.dart';
import 'package:acter_project/public.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class ButtonWithMessage extends StatefulWidget {
  ///// bIsActionButton 매개변수에 따라 액션 버튼인지, 스킵 버튼인지 정해진다
  const ButtonWithMessage(this.client, this.bIsActionButton, {super.key});
  final Client client;
  final bool bIsActionButton; 

  @override
  State<ButtonWithMessage> createState() => _ButtonWithMessageState();
}


class _ButtonWithMessageState extends State<ButtonWithMessage> {
  bool bIsButtonPressed = false;

  @override
  void initState() {
    widget.client.addMessageListener(onListenMessage);
    super.initState();
  }

  @mustBeOverridden
  void onListenMessage(String message) {
      
    if (MessageType.onComplited.equal(message)) {
      setState(() {
        bIsButtonPressed = false;
      });

      if (widget.bIsActionButton) {
        // Action Button

      } else {
        // Skip Button
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: bIsButtonPressed
          ? const Card(
              child: Text('당신의 의지가 전달되고 있습니다..'),
            )
          : ElevatedButton(
              onPressed: () {
                setState(() {
                  bIsButtonPressed = true;
                  widget.client.sendMessage(MessageType.onButtonClicked);
                });
              },
              child: Text(widget.bIsActionButton ? '액션' : '스킵'),
            ),
    );
  }
}