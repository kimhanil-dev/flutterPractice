import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/vmodel/client_message_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:theater_publics/public.dart';

import 'framed_image.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({
    super.key,
  });
  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with TickerProviderStateMixin {
  List<Widget> notificators = [];
  List<AnimationController> controllers = [];
  late ClientMessageBinder msgBinder;
  late AchivementDataManger aDataManager;

  int counter = 0;

  @override
  void initState() {
    super.initState();

    aDataManager = context.read<AchivementDataManger>();

    msgBinder = ClientMessageBinder(client: context.read<Client>());
    msgBinder.bind<Achivement>(MessageType.onAchivement, onAchivement);
  }

  void onAchivement(Achivement achivement) {
    if (mounted) {
      addNotificator(aDataManager.getImage(achivement.id),
          aDataManager.getData(achivement.id)!.name, 0.5.seconds * counter);
      ++counter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [...notificators],
    );
  }

  void addNotificator(Image image, String text, Duration delay) {
    notificators.add(Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FramedImage(
          width: 150,
          height: 150,
          image: image,
        )
            .animate(onInit: (controller) {
              print('inited');
            }, onPlay: (controller) {
              print('played');
            }, onComplete: (controller) {
              print('ended');
              // remove
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  --counter;
                  if (counter == 0 && notificators.isNotEmpty) {
                    notificators.clear();
                  }
                });
              });
            })
            .then(delay: delay)
            .slideY(duration: .5.seconds, begin: -1, end: 0)
            .fadeIn(duration: .5.seconds, begin: 0.0)
            .then(delay: 1.seconds)
            .fadeOut(duration: 300.ms)
            .slideY(duration: 300.ms, begin: 0, end: -1),
        const Gap(25),
        Text(text,
                style: TextStyle(
                    fontSize: 15, color: Theme.of(context).primaryColor))
            .animate()
            .then(delay: delay)
            .slideX(duration: .5.seconds, begin: -1, end: 0)
            .fadeIn(duration: .5.seconds, begin: 0.0)
            .then(delay: 1.seconds)
            .fadeOut(duration: 300.ms)
            .slideX(duration: 300.ms, begin: 0, end: 1)
      ],
    ));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    notificators.clear();

    super.dispose();
  }
}
