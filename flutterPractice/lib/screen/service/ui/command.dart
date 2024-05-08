

class CommandBinder {
  final Map<String,Function(List<String>)> _commands = {};

  /// 이미 해당 커맨드에 등록된 함수가 있다면 assert()를 실행합니다.
  void bindFunctionToCommand(String action,Function(List<String>) function) {
    assert(!_commands.containsKey(action));
    _commands[action] = function;
  }

  /// 등록되지 않은 커맨드 실행시 assert()를 실행합니다.
  void call(String command, List<String> args) {
    assert(_commands.containsKey(command));
    final func = _commands[command];
    func?.call(args);
  }
}