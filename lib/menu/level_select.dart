import 'package:another_pixelart_platformer/menu/items/level_select_button.dart';
import 'package:another_pixelart_platformer/menu/items/rect_button.dart';
import 'package:flutter/material.dart';

class LevelSelect extends StatelessWidget {
  const LevelSelect({super.key});
  final int numOfLevels = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
              const Text(
                "Select Game Level",
                style: TextStyle(
                    color: Color.fromRGBO(192, 204, 166, 1), fontSize: 50.0),
              ),
              const SizedBox(width: 54)
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 5,
              children: List.generate(
                numOfLevels,
                (index) {
                  return LevelSelectButton(mapIndex: index, maxLevels: numOfLevels);
                },
              ),
            ),
          ),
          const Text(
            "More levels coming soon!",
            style: TextStyle(
                color: Color.fromRGBO(192, 204, 166, 1), fontSize: 30.0),
          ),
        ],
      ),
    );
  }
}
