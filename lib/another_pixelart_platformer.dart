import 'dart:async';
import 'dart:io' show Platform;
import 'package:another_pixelart_platformer/components/utils/ingame_button.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:another_pixelart_platformer/components/utils/jump_button.dart';
import 'package:another_pixelart_platformer/components/player.dart';
import 'package:another_pixelart_platformer/components/level.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnotherPixelartPlatformer extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  AnotherPixelartPlatformer(
      {required this.currentLevelIndex, required this.maxLevels});

  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late Level myWorld;

  Player player = Player(character: "Ninja Frog");
  late JoystickComponent joyStick;
  late JumpButton jumpButton;
  bool showControls = false;

  int currentLevelIndex;
  int maxLevels;

  bool playSounds = false;
  bool playMusic = false;
  double soundVolume = 1.0;
  double musicVolume = 0.5;

  late IngameButton pauseButton;

  late CameraComponent cam;
  late SharedPreferences prefs;

  @override
  FutureOr<void> onLoad() async {
    prefs = await SharedPreferences.getInstance();
    await images.loadAllImages();
    musicVolume = prefs.getDouble("game_musicVolume") ?? 0.5;
    soundVolume = prefs.getDouble("game_soundVolume") ?? 1.0;
    playMusic = musicVolume > 0.0;
    playSounds = soundVolume > 0.0;
    if (Platform.isAndroid) {
      showControls = true;
    } else {
      showControls = false;
    }

    if (showControls) {
      createControls();
    }
    pauseButton = IngameButton(
        callback: pauseButtonPressed,
        imagePath: "HUD/Pause.png",
        buttonMargin: const EdgeInsets.only(left: 8, top: 8));
    _loadLevel();
    FlameAudio.bgm.initialize();
    if (playMusic) {
      FlameAudio.bgm.play('bgmusic/01.mp3', volume: musicVolume);
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (showControls) {
      updateJoyStick();
    }
  }

  void pauseButtonPressed() {
    FlameAudio.bgm.pause();
    overlays.add("PauseMenu");
    pauseEngine();
  }

  void resumeButtonPressed() {
    FlameAudio.bgm.resume();
    overlays.remove("PauseMenu");
    resumeEngine();
  }

  void restartButtonPressed() {
    removeWhere((component) => component is Level);
    _loadLevel();
    resumeEngine();
    overlays.remove("PauseMenu");
  }

  void createControls() {
    jumpButton = JumpButton();
    joyStick = JoystickComponent(
        priority: 10,
        knob: SpriteComponent(
          sprite: Sprite(images.fromCache("HUD/Knob.png")),
        ),
        knobRadius: 32,
        background: SpriteComponent(
          sprite: Sprite(images.fromCache("HUD/JoyStick.png")),
        ),
        margin: const EdgeInsets.only(left: 1, bottom: 16));
  }

  void updateJoyStick() {
    switch (joyStick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    currentLevelIndex = (currentLevelIndex + 1) % maxLevels;
    _loadLevel();
  }

  void _loadLevel() {
    myWorld = Level(levelIndex: currentLevelIndex, player: player);
    cam = CameraComponent.withFixedResolution(
        world: myWorld, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;
    if (showControls) {
      cam.viewport.addAll([jumpButton, joyStick]);
    }
    cam.viewport.add(pauseButton);
    addAll([cam, myWorld]);
  }
}
