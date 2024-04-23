import 'package:another_pixelart_platformer/menu/game_mode_select.dart';
import 'package:another_pixelart_platformer/menu/items/custom_menu_button.dart';
import 'package:another_pixelart_platformer/menu/leaderboards.dart';
import 'package:another_pixelart_platformer/menu/options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "Another Pixelart Platformer",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.0,
                ),
              ),
            ),
            CustomMenuButton(
              buttonText: "Play",
              onTapCallback: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const GameModeSelect()));
              },
            ),
            CustomMenuButton(
              buttonText: "Leaderboards",
              onTapCallback: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Leaderboards()));
              },
            ),
            CustomMenuButton(
              buttonText: "Options",
              onTapCallback: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Options()));
              },
            ),
            CustomMenuButton(
              buttonText: "Exit",
              onTapCallback: () {
                FlutterExitApp.exitApp();
              },
            ),
          ],
        ),
      ),
    );
  }
}
