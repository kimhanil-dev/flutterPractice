import 'dart:async';

import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/vmodel/client_message_manager.dart';
import 'package:acter_project/screen/service/screen_effect_manager.dart';
import 'package:acter_project/screen/service/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:theater_publics/public.dart';

/// set(image, posX, posY)
class UIContinue extends UI {
  UIContinue(this.client,this.commandManager, {super.key});
  final CommandManager commandManager;
  final Client client;

  @override
  bool get isForward => false;

  @override
  State<UIContinue> createState() => UIContinueState();
}

class UIContinueState extends State<UIContinue> with TickerProviderStateMixin {
  late AnimationController controller;
  Timer? _timer;
  int count = 20;

  bool isDoHelp = false;
  bool isVisible = false;

  late ClientMessageBinder msgBinder;

  @override
  void initState() {
    super.initState();

    msgBinder = ClientMessageBinder(client: widget.client);
    msgBinder.bind<StringData>(MessageType.onVoteComplited, onActionVoted);

    widget.client.sendMessage(
            message: MessageType.onUpdateButtonState); // 도움 업적(1930)


    controller = AnimationController(
      vsync: this,
      duration: 2000.ms,
      value: 0,
    );

    init();
  }

  @override
  Widget build(BuildContext context) {
    return isVisible
        ? Stack(children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue ...',
                      style: TextStyle(color: Colors.white, fontSize: 100),
                    ),
                    Text(
                      '$count',
                      style: TextStyle(color: Colors.white, fontSize: 90),
                    )
                  ],
                ).animate(controller: controller, autoPlay: false).swap(
                      builder: (context, child) => Text('Game Over',
                          style: TextStyle(color: Colors.white, fontSize: 100)),
                    ),
              ),
            ),
          ])
        : Container();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void init() {
    if(_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer.periodic(1.seconds, (timer) {
      if (count == 0) {
        _timer!.cancel();
        controller.forward();
      } else {
        setState(() {
          --count;
        });
      }
    });
  }

  void onActionVoted(StringData voteResult) {
    final actionVoteResult = voteResult.value.split(',');

    if (actionVoteResult[0] != 'action') {
      return;
    }

    if (actionVoteResult[1] == 'true') {
      if (!isDoHelp) {
        // 도움 성공, UI 삭제
        return;
      } else {
        // 컨티뉴 성공
        isVisible = false;
        // 다시 도움 요청
        isDoHelp = false;
        widget.client.sendMessage(
            message: MessageType.startInstanceActionVote,
            object: IntData(1930)); // 도움 업적(1930)
      }
    } else {
      if (!isDoHelp) {
        // 도움 실패
        isDoHelp = true;
        // Action 투표 시작
        widget.client.sendMessage(
            message: MessageType.startInstanceActionVote,
            object: IntData(99930)); // 루프 업적(99930)
        isVisible = true;
        return;
      } else {
        // 진정한 실패
        // 크래딧 전환
        controller.forward();
      }
    }
  }
}
