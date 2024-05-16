import 'package:acter_project/client/Services/client.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:theater_publics/public.dart';
import 'package:theater_publics/vote.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../curve/sin_curve.dart';

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

    widget.client.sendMessage(message: MessageType.requestCurrentVotes);
  }

  @mustBeOverridden
  void onListenMessage(MessageData message) {
    switch (message.messageType) {
      case MessageType.requestCurrentVotes:
        if (widget.voteType == VoteType.skip) {
          setState(() {
            isActivated = message.datas[0] == 1 ? true : false;
          }); // skip vote existed?
        } else {
          setState(() {
            isActivated = message.datas[1] == 1 ? true : false;
          }); // action vote existed?
        }
        break;
      case MessageType.onUpdateButtonState:
        {
          setState(() {
            var buttonState = ButtonStates.fromBytes(message.datas);
            if (widget.voteType == VoteType.skip) {
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
            ? Text(
                '당신의 의지가 전달되고 있습니다..',
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 15),
              )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .fade(duration: 1.5.seconds, curve: SinCurve())
            : CustomButton(
                color: getColor(),
                isActivated: isActivated,
                onPressed: onPressed,
                text: widget.voteType == VoteType.action ? '액션' : '스킵',
              ));
  }

  Color getColor() {
    if (isActivated) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Colors.grey;
    }
  }

  void onPressed() {
    setState(() {
      bIsButtonPressed = true;
    });

    Future.delayed(3.seconds).then((value) => widget.client.sendMessage(
        message: MessageType.onButtonClicked, object: widget.voteType));
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.text,
      this.size = const Size(250,50),
      required this.color,
      required this.isActivated,
      required this.onPressed});

  final String text;
  final Size size;
  final Color color;
  final bool isActivated;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/ui/Button12.svg',
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            Text(
              text,
              style: TextStyle(color: color),
            ),
          ],
        ),
      ),
      onPressed: isActivated ? onPressed : null,
    );
  }
}
