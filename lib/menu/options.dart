import 'package:another_pixelart_platformer/menu/items/rect_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Options extends StatefulWidget {
  const Options({super.key});

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  late SharedPreferences prefs;
  double musicVolume = 0.5;
  double soundVolume = 0.5;

  _OptionsState() {
    initStuff();
  }

  void initStuff() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      musicVolume = prefs.getDouble("game_musicVolume") ?? 0.5;
      soundVolume = prefs.getDouble("game_soundVolume") ?? 0.5;
    });
  }

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            children: [
              const Text("Sound Volume",
                  style: TextStyle(color: Colors.white, fontSize: 50.0)),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                        value: soundVolume,
                        onChangeEnd: (value) =>
                            prefs.setDouble("game_soundVolume", value),
                        onChanged: (value) =>
                            setState(() => soundVolume = value)),
                  ),
                  SizedBox(
                    width: 50,
                    child: IconButton(
                      onPressed: () => setState(() {
                        soundVolume = (soundVolume == 0) ? 0.5 : 0.0;
                        prefs.setDouble("game_soundVolume", soundVolume);
                      }),
                      icon: Builder(
                        builder: (context) {
                          if (soundVolume == 0.0) {
                            return const Icon(Icons.music_note);
                          }
                          return const Icon(Icons.music_off);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Text("Music Volume",
                  style: TextStyle(color: Colors.white, fontSize: 50.0)),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                        value: musicVolume,
                        onChangeEnd: (value) =>
                            prefs.setDouble("game_musicVolume", value),
                        onChanged: (value) {
                          setState(() => musicVolume = value);
                        }),
                  ),
                  SizedBox(
                    width: 50,
                    child: IconButton(
                      onPressed: () => setState(() {
                        musicVolume = (musicVolume == 0) ? 0.5 : 0.0;
                        prefs.setDouble("game_musicVolume", musicVolume);
                      }),
                      icon: Builder(builder: (context) {
                        if (musicVolume == 0.0) {
                          return const Icon(Icons.music_note);
                        }
                        return const Icon(Icons.music_off);
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }
}
