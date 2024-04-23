import 'package:another_pixelart_platformer/menu/items/rect_button.dart';
import 'package:flutter/material.dart';

class Leaderboards extends StatelessWidget {
  const Leaderboards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Row(
          children: [
            RectButton(
              backgroundPath: "assets/images/HUD/DefaultRect.png",
              iconPath: "assets/images/HUD/ArrowLeft-Thin.png",
              padding: const EdgeInsets.all(16),
              onTapCallback: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        const Text("Coming Soon!",
            style: TextStyle(color: Colors.white, fontSize: 50.0)),
      ]),
    );
  }
}
