import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GamePlay extends StatelessWidget {
  late final AnotherPixelartPlatformer game;
  final int currentLevel;
  final int maxLevels;
  GamePlay({required this.currentLevel, required this.maxLevels, super.key}) {
    game = AnotherPixelartPlatformer(
        currentLevelIndex: currentLevel, maxLevels: maxLevels);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: GameWidget(
          game: game,
          overlayBuilderMap: {
            'PauseMenu':
                (BuildContext context, AnotherPixelartPlatformer game) {
              return DefaultTextStyle(
                style: GoogleFonts.pixelifySans(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(33, 31, 48, 1.0),
                            border: Border.all(
                              color: const Color.fromRGBO(72, 72, 48, 1.0),
                              width: 3.0,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                "Pause Menu",
                                style: TextStyle(fontSize: 50.0),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => game.resumeButtonPressed(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        "assets/images/HUD/Resume.png",
                                        width: 56,
                                        height: 56,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => game.restartButtonPressed(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        "assets/images/HUD/Restart.png",
                                        width: 56,
                                        height: 56,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        "assets/images/HUD/ToMenu.png",
                                        width: 56,
                                        height: 56,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        ));
  }
}
