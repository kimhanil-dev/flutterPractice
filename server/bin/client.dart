import 'dart:async';
import 'dart:io';
void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = args[0];

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  Socket.connect(ip, 8080).then((value){
    value.listen((event) { 
      print(String.fromCharCodes(event));
    });
  });
}
