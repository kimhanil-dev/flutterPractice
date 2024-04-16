import 'package:acter_project/client/client.dart';
import 'package:acter_project/public.dart';
import 'package:acter_project/server/vote.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class ButtonWithMessage extends StatefulWidget {
  ///// bIsActionButton 매개변수에 따라 액션 버튼인지, 스킵 버튼인지 정해진다
  const ButtonWithMessage(this.client, this.voteType, {super.key});
  final Client client;
  final VoteType voteType;

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
  void onListenMessage(MessageData message) {
      
    if (MessageType.onComplited == message.messageType) {
      setState(() {
        bIsButtonPressed = false;
      });
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
                  widget.client.sendMessage(message: MessageType.onButtonClicked, datas: [widget.voteType.index]);
                });
              },
              child: Text(widget.voteType == VoteType.action ? '액션' : '스킵'),
            ),
    );
  }
}