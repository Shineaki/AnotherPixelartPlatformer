import 'package:another_pixelart_platformer/menu/gameplay.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelSelectButton extends StatefulWidget {
  final int mapIndex;
  final int maxLevels;
  const LevelSelectButton({required this.mapIndex,required this.maxLevels, super.key});
  @override
  State<StatefulWidget> createState() => LevelSelectState();
}

class LevelSelectState extends State<LevelSelectButton> {
  int yourStars = 0;

  void getStuff() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      yourStars = prefs.getInt('stars_${widget.mapIndex}') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    getStuff();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GamePlay(
              currentLevel: widget.mapIndex,
              maxLevels: widget.maxLevels
            ),
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset("assets/images/HUD/mapbg.png"),
              Text(
                (widget.mapIndex + 1).toString(),
                style: const TextStyle(fontSize: 25.0),
              ),
            ],
          ),
          Image.asset("assets/images/HUD/Stars/$yourStars-3.png")
        ],
      ),
    );
  }
}
