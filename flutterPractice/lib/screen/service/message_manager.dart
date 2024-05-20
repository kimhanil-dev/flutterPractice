import 'package:theater_publics/public.dart';

abstract interface class IMessageListener {
  void listen(dynamic parsedData);
}

class MessageListener<E> implements IMessageListener{
  MessageListener(this._onMessage);
  final void Function(E) _onMessage;
  
  @override
  void listen(dynamic parsedData) {
    _onMessage(parsedData);
  }
}

class MessageManager {
  Map<MessageType, List<IMessageListener>> listeners = {};

  void addListener(MessageType type, IMessageListener listener) {
    (listeners[type] ??= []).add(listener);
  }

  void notifyMessage(MessageData msgData) {
    listeners[msgData.messageType]?.forEach((element) {
      element.listen(msgData.messageType.parser!(msgData));
    });
  }
}
