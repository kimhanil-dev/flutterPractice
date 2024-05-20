import 'package:acter_project/client/Services/archive.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:acter_project/client/curve/sin_curve.dart';
import 'package:acter_project/client/vmodel/achivement_notificator.dart';
import 'package:acter_project/client/vmodel/client_message_manager.dart';
import 'package:acter_project/client/widgets/widget/notification.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:theater_publics/public.dart';
import 'package:theater_publics/vote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/corner.dart';
import '../widget/message_button.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage>
    with AutomaticKeepAliveClientMixin<VotePage>, TickerProviderStateMixin {
  late Archive archive;
  late Client client;

  late AchivementDataManger achivementDataManger;
  late AchivementNotificator notificator;
  late ClientMessageBinder msgBinder;
  late AnimationController controller;

  bool isLocked = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    achivementDataManger = context.read<AchivementDataManger>();

    controller = AnimationController(vsync: this, duration: 2.seconds);

    // Bind To MessageType
    msgBinder = ClientMessageBinder(client: client = context.read<Client>());
    {
      msgBinder.bind<Achivement>(MessageType.onAchivement, onAchivement);
      msgBinder.bind<BoolData>(MessageType.onLockUpdate, (p0) {
        isLocked = p0.condition;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    archive = Provider.of<Archive>(context);

    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: isLocked
              ? [
                  Image.asset(
                    'assets/result.png',
                    color: Theme.of(context).primaryColor,
                  )
                      .animate(
                        controller: controller,
                        onPlay: (controller) => controller.repeat(),
                      )
                      .blur(
                          duration: 2.seconds,
                          curve: SinCurve(),
                          begin: Offset(1, 1),
                          end: Offset(4, 4))
                      .scale(
                          duration: 1.seconds,
                          curve: SinCurve(),
                          begin: Offset(1, 1),
                          end: Offset(2, 2))
                      .fadeOut(duration: 2.seconds, curve: SinCurve()),
                  Image.asset(
                    'assets/result.png',
                    color: Theme.of(context).primaryColor,
                  )
                ]
              : [const Corner(), ..._pageBuilder()],
        ),
      ),
    );
  }

  List<Widget> _pageBuilder() {
    final List<Widget> widgets = [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 200,
              child: NotificationWidget(),
            ),
            const SizedBox(
              width: 20,
              height: 20,
            ),
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

    return widgets;
  }

  void onAchivement(Achivement achivement) {
    var data = achivementDataManger.getData(achivement.id);
    if (data != null) {
      archive.addAchivement(achivement.id);
      //addNotiWidget(achivementDataManger.getImage(achivement.id), data.name);
    }
  }
}
