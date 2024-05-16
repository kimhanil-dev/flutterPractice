class CommandBinder {
  final Map<String, List<Function(List<String>)>> _commands = {};

  void bindFunctionToCommand(String action, Function(List<String>) function) {
    (_commands[action] ??= []).add(function);
  }

  void call(String command, List<String> args) {
    assert(_commands.containsKey(command));
    for (var e in _commands[command]!) {
      e(args);      
    }
  }
}
