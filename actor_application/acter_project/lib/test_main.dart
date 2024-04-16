import 'dart:io';

import 'package:acter_project/public.dart';

void main() async {
  ServerSocket localServer = await ServerSocket.bind('localhost', 55555);
  Socket toServer = await Socket.connect('localhost', 55555);

  MessageHandler.sendMessage(toServer, MessageType.onAchivement,datas: [15]);

  toServer.listen(
    (event) {
      print(String.fromCharCodes(event));
    },
  );
  localServer.listen(
    (event) {
      event.listen((event) {
        var messages = MessageHandler.getMessages(event);
        for (var message in messages) {
          print(message.messageType.name);
          print(message.datas);
        }
      });
    },
  );
}
