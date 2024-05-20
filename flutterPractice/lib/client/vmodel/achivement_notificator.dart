import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/vmodel/client_message_manager.dart';
import 'package:acter_project/client/widgets/widget/notification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theater_publics/achivement.dart';
import 'package:theater_publics/public.dart';

class NotiData {
  final Image image;
  final String text;

  NotiData(this.image, this.text);
}

/// Server에서 onAchivement 데이터를 수신하고, 화면에 출력하는 역할을 합니다.
class AchivementNotificator extends StatefulWidget {
  const AchivementNotificator({super.key});

  @override
  State<AchivementNotificator> createState() => _AchivementNotificatorState();
}

class _AchivementNotificatorState extends State<AchivementNotificator>
    with TickerProviderStateMixin {
  NotificationWidget? viewingWidget;
  final List<NotificationWidget> _notis = [];

  int waitCounter = 0;

  late AchivementDataManger _aDataManager;
  late ClientMessageBinder _msgBinder;

  @override
  void initState() {
    super.initState();

    _aDataManager = context.read<AchivementDataManger>();
    _msgBinder = ClientMessageBinder(client: context.read<Client>());
    _msgBinder.bind<Achivement>(MessageType.onAchivement, onAchivement);
  }

  void onAchivement(Achivement achivement) {
    final AchivementData? aData = _aDataManager.getData(achivement.id);
    if (aData == null) {
      print('undefined achivement data : id : {$aData}');
      return;
    }

    setState(() {
      _notis.add(NotificationWidget());
    });
  }

  // on notification fadeout complited
  void _onNotificationFadeOut(NotificationWidget notificator) {
    if (waitCounter == 0) {
      setState(() {
        _notis.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
