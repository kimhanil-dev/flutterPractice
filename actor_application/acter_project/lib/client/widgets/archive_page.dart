import 'package:acter_project/client/main.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ArchivePage extends StatelessWidget {
  ArchivePage({super.key});
  final archive = Archive.init();

  @override
  Widget build(BuildContext context) {
    archive.init();
    return Scaffold(
      body: GridView(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        children: [
          for (var grid in archive.getAllAchivements())
            Row(
              children: [
                Expanded(
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: FittedBox(
                          child: grid.image,
                          fit: BoxFit.fill,
                        ))),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      grid.name,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    AutoSizeText(
                      grid.text,
                      style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ))
              ],
            ),
        ],
      ),
    );
  }
}
