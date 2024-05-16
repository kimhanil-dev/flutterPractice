import 'package:flutter/material.dart';

class FramedImage extends StatelessWidget {
  const FramedImage({
    super.key,
    required this.width,
    required this.height,
    required this.image,
  });

  final Image image;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
       width: width,
       height: height, 
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Image(
              image: image.image,
              fit: BoxFit.fill,
            ),
          ),
          Image.asset('assets/images/ui/Square1.png')
        ],
      ),
    );
  }
}
