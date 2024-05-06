import 'dart:typed_data';

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