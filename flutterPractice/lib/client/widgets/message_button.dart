import 'package:acter_project/client/Services/client.dart';
import 'package:theater_publics/public.dart';
import 'package:theater_publics/vote.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MessageButtton extends StatefulWidget {
  const MessageButtton(this.client, this.voteType, {super.key});
  final Client client;
  final VoteType voteType;

  @override
  State<MessageButtton> createState() => _MessageButttonState();
}

class _MessageButttonState extends State<MessageButtton> {
  bool bIsButtonPressed = false;
  bool isActivated = false;

  @override
  void initState() {
    widget.client.addMessageListener(onListenMessage);
    super.initState();
  }

  @mustBeOverridden
  void onListenMessage(MessageData message) {
    switch (message.messageType) {
      case MessageType.onUpdateButtonState:
        {
          setState(() {
            var buttonState = ButtonStates.fromBytes(message.datas);
            if(widget.voteType == VoteType.skip) {
              isActivated = buttonState.isSkipEnabled;
            } else {
              isActivated = buttonState.isActionEnabled;
            }
          });
        }
        break;
      case MessageType.onVoteComplited:
        {
          setState(() {
            bIsButtonPressed = false;
            isActivated = false;
          });
        }
        break;
      default:
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
              onPressed: isActivated
                  ? () {
                      setState(() {
                        bIsButtonPressed = true;
                        widget.client.sendMessage(
                            message: MessageType.onButtonClicked,
                            object: widget.voteType);
                      });
                    }
                  : null,
              child: Text(widget.voteType == VoteType.action ? '액션' : '스킵'),
            ),
    );
  }
}
