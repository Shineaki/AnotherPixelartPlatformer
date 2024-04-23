import 'package:flutter/material.dart';

class RectButton extends StatelessWidget {
  final String backgroundPath;
  final String iconPath;
  final Function onTapCallback;
  final EdgeInsets padding;
  const RectButton(
      {required this.backgroundPath,
      required this.iconPath,
      required this.padding,
      required this.onTapCallback,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
          onTap: () {
            onTapCallback();
          },
          child: SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(backgroundPath),
                SizedBox(width: 28, height: 28, child: Image.asset(iconPath)),
              ],
            ),
          )),
    );
  }
}
