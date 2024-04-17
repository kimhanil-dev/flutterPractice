import 'package:acter_project/client/client.dart';
import 'package:acter_project/public.dart';
import 'package:acter_project/server/vote.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MessageSendButton extends StatefulWidget {
  ///// bIsActionButton 매개변수에 따라 액션 버튼인지, 스킵 버튼인지 정해진다
  const MessageSendButton(this.client, this.voteType, {super.key});
  final Client client;
  final VoteType voteType;

  @override
  State<MessageSendButton> createState() => _MessageSendButtonState();
}


class _MessageSendButtonState extends State<MessageSendButton> {
  bool bIsButtonPressed = false;

  @override
  void initState() {
    widget.client.addMessageListener(onListenMessage);
    super.initState();
  }

  @mustBeOverridden
  void onListenMessage(MessageData message) {
      
    if (MessageType.onVoteComplited == message.messageType) {
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
                  widget.client.sendMessage(message: MessageType.onButtonClicked, object: widget.voteType);
                });
              },
              child: Text(widget.voteType == VoteType.action ? '액션' : '스킵'),
            ),
    );
  }
}