import 'package:flutter/material.dart';

class AchivementNotificator {
  AchivementNotificator(this.tickerProvider);
  final TickerProviderStateMixin tickerProvider;

  List<Notification> notifications = [];
  List<Future> delayedNotis = [];
  int delayCounter = 0;

  Future<void> showNotification(ImageProvider<Object> image, String name,
      Duration autoHideTime, Size destination, Duration animTime) async {
    return Future.delayed(Duration(seconds: 1 * (delayCounter++)))
        .then((value) async {
      _showNotification(image, name, autoHideTime, destination, animTime)
          .then((value) => --delayCounter);
    });
  }

  Future<void> _showNotification(ImageProvider<Object> image, String name,
      Duration autoHideTime, Size destination, Duration animTime) async {
    final noti = Notification(notifications.length, image, name, destination,
        autoHideTime, tickerProvider, animTime);
    notifications.add(noti);
    await noti.done;
    notifications.remove(noti);
    return;
  }

  List<Widget> getAllNotiWidgets() {
    return notifications.map((e) => e.getNotificator()).toList();
  }
}

class Notification {
  Notification(this.index, this.image, this.name, this.destination,
      this.autoHideTime, TickerProviderStateMixin ticker, Duration animTime) {
    controller = AnimationController(vsync: ticker, duration: animTime);
    lerp = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

    _done = () async {
      await controller.forward();
      await Future<void>.delayed(autoHideTime);
      await controller.reverse();
      return this;
    }.call();
  }

  final int index;
  late AnimationController controller;
  late Animation<double> lerp;
  final Duration autoHideTime;
  final Size destination;
  final ImageProvider image;
  final String name;

  late Future<Notification> _done;
  Future<Notification> get done => _done;

  Widget getNotificator() {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Opacity(
            opacity: lerp.value,
            child: Container(
              width: destination.width * lerp.value,
              height: destination.height * lerp.value,
              color: Colors.white,
              padding: const EdgeInsets.all(15),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      image: image,
                      alignment: Alignment.center,
                    ),
                    Text(name),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
