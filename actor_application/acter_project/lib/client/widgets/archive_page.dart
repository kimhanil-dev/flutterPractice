import 'package:acter_project/client/Services/archive.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';


class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.loaderOverlay.show();
    var archive = Provider.of<Archive>(context);
    ArchiveSaveLoader.load(archive)
        .then((value) {
          context.loaderOverlay.hide();
        });

    return Scaffold(
      body: GridView(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        children: [
          for (var id in archive.achivements)
            Row(
              children: [
                Expanded(
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Image.network(
                              'https://drive.google.com/uc?export=view&id=14QBvq8HL7-jSmU0-PLDxZ6mt4IFD1i3p'),
                        ))),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      id.toString(),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    AutoSizeText(
                      id.toString(),
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
