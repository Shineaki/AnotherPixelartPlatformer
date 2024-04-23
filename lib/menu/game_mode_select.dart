import 'package:another_pixelart_platformer/menu/items/custom_menu_button.dart';
import 'package:another_pixelart_platformer/menu/items/rect_button.dart';
import 'package:another_pixelart_platformer/menu/level_select.dart';
import 'package:flutter/material.dart';

class GameModeSelect extends StatelessWidget {
  const GameModeSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RectButton(
                  backgroundPath: "assets/images/HUD/DefaultRect.png",
                  iconPath: "assets/images/HUD/ArrowLeft-Thin.png",
                  padding: const EdgeInsets.only(left: 16),
                  onTapCallback: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Text("Select Game Mode",
                    style: TextStyle(
                        color: Color.fromRGBO(192, 204, 166, 1),
                        fontSize: 50.0)),
                const SizedBox(width: 54)
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomMenuButton(
                  buttonText: "Normal",
                  onTapCallback: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LevelSelect()));
                  },
                ),
                CustomMenuButton(
                  buttonText: "Endless",
                  buttonColor: Colors.white24,
                  onTapCallback: () {},
                ),
                CustomMenuButton(
                  buttonColor: Colors.white24,
                  buttonText: "Speedrun",
                  onTapCallback: () {},
                ),
              ],
            ),
            SizedBox(width: 30)
          ],
        ),
      ),
    );
  }
}
