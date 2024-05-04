import 'dart:typed_data';

import 'package:acter_project/client/Services/client.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:theater_publics/public.dart';

abstract interface class ScreenMessageListener {
  void onMessage(ScreenMessage message); 
}

class ScreenMessage implements MessageTransableObject {
  ScreenMessage(this.msgType, {this.datas});
  ScreenMessage.fromData(List<int> datas) {
    msgType = MessageType.values[datas[0]];
    this.datas = datas.sublist(1);
  }

  late MessageType msgType;
  List<int>? datas;

  @override
  bool equal(Uint8List data) {
    return ScreenMessage.fromData(data).msgType == msgType;
  }

  @override
  List<int> getMessage() {
    return [msgType.index, ...(datas ?? [])];
  }
}

class EventManager {
  Client client = Client(clientType: Who.screen);

  List<ScreenMessageListener> messageListeners = [];

  void addOnScreenMessage(ScreenMessageListener listener) {
    messageListeners.add(listener);
  }

  void connect() async {
    var config = await GlobalConfiguration().loadFromAsset('config.json');
    client.connectToServer(config.getValue<String>('server-ip'),
        config.getValue<int>('server-port'), (p0) {});
    client.addMessageListener(_listen);
  }

  void init() {}

  void _listen(MessageData data) {
    if (data.messageType == MessageType.screenMessage) {
      for (var listener in messageListeners) {
          listener.onMessage(ScreenMessage.fromData(data.datas));
      }
    }
  }
}
