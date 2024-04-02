

import 'dart:io';
import 'dart:typed_data';

class Server {
  ServerSocket? server;
  List<Socket> clients = [];
  int skipCount = 0;
  int actionCount = 0;

  void init() async {
    server = await ServerSocket.bind(InternetAddress.anyIPv4, 55555);
    server!.listen((client) {
      handleConnection(client);
    });
  }

  void broadcastMessage(String message) {
    for (var client in clients) {
      client.write(message);
    }
  }

  // 클라이언트 연결 관리 및 로직 처리( 액션, 스킵 )
  void handleConnection(Socket client) {
    print('Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}');

    clients.add(client);

    // listen for events from the client
    client.listen(
      // handle data from the client
      handleClientData,

      // handle errors
      onError: (error) {
        print(error);
        client.close();
        clients.remove(client);
      },

      // handle the client closing the connection
      onDone: () {
        print('Client left');
        client.close();
        clients.remove(client);
      },
    );
  }

  void handleClientData(Uint8List data) async {
      await Future.delayed(const Duration(seconds: 1));
      final message = String.fromCharCodes(data);
      if (message == 'skip') {
        ++skipCount;
        if (skipCount >= (clients.length * 0.6)) {
          for (var client in clients) {
            client.write('skip_complite');
            skipCount = 0;
          }
        }
      } else if (message == 'action') {
        ++actionCount;
        for (var client in clients) {
          client.write('action_complite');
          actionCount = 0;
        }
      }
    }

  // send achivement id to client
  void sendAchivement(Socket client, int id) {
    client.write(id.toString());
  }
}