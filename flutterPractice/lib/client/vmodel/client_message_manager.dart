import 'package:acter_project/client/Services/client.dart';
import 'package:theater_publics/public.dart';

class ClientMessageBinder {
  final Client _client;
  final Map<MessageType, List<Function>> _bindings = {};

  ClientMessageBinder({required Client client}) : _client = client {
    _client.addMessageListener(_listen);
  }

  // 타입 무결성 검사 실시하는 곳
  void bind<E>(MessageType msgType, Function(E) callback) {
    assert(msgType.runtimeType == E.runtimeType);
    
    (_bindings[msgType] ??= []).add(callback);
  }

  void _listen(MessageData msgData) {
    _bindings[msgData.messageType]
        ?.forEach((element) => element(msgData.messageType.parser!(msgData))); // 암묵적으로 형변환이 이루어지는가?
  }
}



