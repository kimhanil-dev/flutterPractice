import 'dart:typed_data';

import 'package:acter_project/client/Services/client.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:theater_publics/public.dart';

class ScreenMessage implements MessageTransableObject {
  ScreenMessage(this.msgType, this.datas);
  ScreenMessage.fromData(List<int> datas) {
    msgType = MessageType.values[datas[0]];
    this.datas = datas.sublist(1);
  }

  late MessageType msgType;
  late List<int> datas;

  @override
  bool equal(Uint8List data) {
    return true;
  }

  @override
  List<int> getMessage() {
    return [msgType.index, ...datas];
  }
}

class Background {
  Background(this.id, this.name, this.fileName);
  int id = 0;
  String fileName;
  String name;

  Image getImage() {
    try {
      return Image.asset('assets/images/bg/$fileName');
    } catch (e) {
      return Image.asset('assets/images/bg/bg_error.jpg');
    }
  }
}

class EventManager {
  Client client = Client(clientType: Who.screen);

  late Function(Image) onBackgroundChanged;

  void bindOnBackgroundChanged(Function(Image) callback) {
    onBackgroundChanged = callback;
  }

  void connect() async {
    var config = await GlobalConfiguration().loadFromAsset('config.json');
    client.connectToServer(config.getValue<String>('server-ip'),
        config.getValue<int>('server-port'), (p0) {});
    client.addMessageListener(_listen);
  }

  void init() {}

  List<Background> imageDatas = [
    Background(0, 'bg_0.jpg', '블랙'),
    Background(0, 'bg_1.jpg', '볼케이노')
  ];

  void _listen(MessageData data) {
    if (data.messageType == MessageType.screenMessage) {
      var screenMessage = ScreenMessage.fromData(data.datas);
      switch (screenMessage.msgType) {
        case MessageType.changeImage:
          var imageId = data.datas[0];
          onBackgroundChanged(Image.asset(imageDatas[imageId].fileName));
          break;
        default:
      }
    }
  }
}
