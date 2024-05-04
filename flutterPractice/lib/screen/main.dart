
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/screen/event_manager.dart';
import 'package:acter_project/screen/screen_effect_manager.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:theater_publics/public.dart';

abstract class ScreenEffect {
  ScreenEffect(this.chapter, this.id, this.name);
  int chapter;
  int id;
  String name;

  void startEffect();
}

class ImageEffect extends ScreenEffect {
  ImageEffect(this._bgImageSetter, this._bgImage,super.chapter, super.id, super.name);

  final BackgroundImageSetter _bgImageSetter;
  final Image _bgImage;

  @override
  void startEffect() {
    _bgImageSetter.setImage(_bgImage);
  }
}

class SoundEffect extends ScreenEffect {
  SoundEffect(this.audioPlayer, this.audioPath,super.chapter, super.id, super.name);

  final String audioPath;
  final AudioPlayer audioPlayer;


  @override
  void startEffect() {
    audioPlayer.setAsset(audioPath);
    audioPlayer.play();
  }
}

class VfxEffect extends ScreenEffect {
  VfxEffect(super.chapter, super.id, super.name);



  @override
  void startEffect() {
  }
}



void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ScreenPage(),);
  }
}

class ScreenPage extends StatefulWidget {  @override
  State<ScreenPage> createState() => _ScreenPageState();
}

class _ScreenPageState extends State<ScreenPage> {
  Client client = Client(clientType: Who.screen);
  late ScreenEffectManager screenEffectManager;
  final EventManager eventManager = EventManager();
  Image? image = Image.asset('assets/images/bg/bg_0.jpg');

  @override
  void initState() {
    super.initState();

    GlobalConfiguration().loadFromAsset('config.json').then((config){
        client.connectToServer(config.getValue<String>('server-ip'),
        config.getValue<int>('server-port'), (p0) {});
    });

    screenEffectManager = ScreenEffectManager((){setState(() {});});
    client.addMessageListener(screenEffectManager.onMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        screenEffectManager.backgroundImage,
      ],),
    );
  }
 }
