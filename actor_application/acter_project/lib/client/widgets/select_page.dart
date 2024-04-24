import 'package:acter_project/client/Services/achivement_image_loader.dart';
import 'package:acter_project/client/Services/archive.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/public.dart';
import 'package:acter_project/server/vote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'button_with_message.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> with AutomaticKeepAliveClientMixin<SelectPage>{
  bool bIsActionEnabled = false;
  late Archive archive;
  late Client client;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    client = context.read<Client>();
    client.addMessageListener((message) {
      switch (message.messageType) {
        case MessageType.activateActionButton:
          {
            setState(() {
              bIsActionEnabled = true;
            });
          }
          break;
        case MessageType.onAchivement:
          {
            var achivementId = int.parse(String.fromCharCodes(message.datas));
            archive.addAchivement(achivementId);

            overlay(achivementId);
          }
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    archive = Provider.of<Archive>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MessageSendButton(client, VoteType.skip),
            const SizedBox(
              width: 20,
              height: 20,
            ),
            MessageSendButton(client, VoteType.action),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  void overlay(int achivementId) {
    removeOverlay();

    assert(_overlayEntry == null);

    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 4.0)),
            child: AchivementImageLoader.getImage(achivementId),
          ),
        ),
      );
    });

    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntry!);

    Future<void>.delayed(const Duration(seconds: 5))
        .then((value) => removeOverlay());
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }
  
  @override
  bool get wantKeepAlive => true;
}
