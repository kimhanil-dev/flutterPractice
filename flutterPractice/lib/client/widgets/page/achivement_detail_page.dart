import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../widget/framed_image.dart';

class AchivementDetailPage extends StatelessWidget {
  final int achiveId;

  const AchivementDetailPage({super.key, required this.achiveId});

  @override
  Widget build(BuildContext context) {
    var achivementData = Provider.of<AchivementDataManger>(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Align(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                  tag: achiveId.toInt(),
                  child: FramedImage(
                      width: 150,
                      height: 150,
                      image: achivementData.getImage(achiveId))),
              const Gap(20),
              Text(
                achivementData.getData(achiveId)!.name,
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
