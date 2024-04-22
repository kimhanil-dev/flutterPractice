import 'package:acter_project/client/achivementImageLoader.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  late AchivementImageLoader imageLoader;
  List<String> imageWebUrls = [];
  @override
  void initState() {
    imageLoader = AchivementImageLoader();
    imageLoader.downloadImages();
    imageLoader.getImageWebLinks().then((value) {
      setState(() {
        imageWebUrls.addAll(value);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: Scaffold(
        body: GridView.builder(
            shrinkWrap: true,
            itemCount: imageWebUrls.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10),
            itemBuilder: (BuildContext context, int index) {
              return Image.network(imageWebUrls[index]);
            }),
      ),
    );
  }
}
