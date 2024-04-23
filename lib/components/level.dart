import 'dart:async';
import 'package:another_pixelart_platformer/components/objects/blue_bird.dart';
import 'package:another_pixelart_platformer/components/objects/trunk.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:another_pixelart_platformer/components/utils/background_tile.dart';
import 'package:another_pixelart_platformer/components/objects/checkpoint.dart';
import 'package:another_pixelart_platformer/components/objects/chicken.dart';
import 'package:another_pixelart_platformer/components/utils/collision_block.dart';
import 'package:another_pixelart_platformer/components/objects/fruit.dart';
import 'package:another_pixelart_platformer/components/player.dart';
import 'package:another_pixelart_platformer/components/objects/saw.dart';
import 'package:another_pixelart_platformer/components/objects/spikes.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Level extends World with HasGameRef<AnotherPixelartPlatformer> {
  final int levelIndex;
  final Player player;
  Level({required this.levelIndex, required this.player});
  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];
  int currentStars = 0;
  int remainingFruits = 0;
  int initFruits = 0;

  @override
  FutureOr<void> onLoad() async {
    currentStars = 0;
    remainingFruits = 0;
    initFruits = 0;
    player.started = false;
    player.current = PlayerState.idle;
    level = await TiledComponent.load(
      "level_$levelIndex.tmx",
      Vector2(16, 16),
      priority: -2,
    );
    add(level);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();
    _countDown();
    return super.onLoad();
  }

  void fruitCollected() {
    remainingFruits -= 1;
    if (remainingFruits < initFruits) {
      currentStars = 1;
    }
    if (remainingFruits == 0) {
      currentStars = 2;
    }
  }

  void _countDown() async {
    final regular = TextPaint(
      style: GoogleFonts.pixelifySans(
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 50.0,
          shadows: [Shadow(color: Colors.black, blurRadius: 5)],
        ),
      ),
    );
    var abc = TextComponent(
        position: Vector2(level.size.x / 2, level.size.y / 2),
        text: "3",
        anchor: Anchor.center,
        size: Vector2(50, 50),
        textRenderer: regular);
    add(abc);
    await Future.delayed(const Duration(milliseconds: 500));
    abc.text = "2";
    await Future.delayed(const Duration(milliseconds: 500));
    abc.text = "1";
    await Future.delayed(const Duration(milliseconds: 500));
    remove(abc);
    player.started = true;
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer("Background");
    final backgroundColor =
        backgroundLayer?.properties.getValue("BackgroundColor");
    final backgroundTile = BackgroundTile(
        color: backgroundColor ?? "Gray", position: Vector2(0, 0));
    add(backgroundTile);
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("SpawnPoints");

    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          player.position = spawnPoint.position;
          player.startingPosition = spawnPoint.position;
          player.scale.x = 1;
          add(player);
          break;
        case "Fruit":
          remainingFruits += 1;
          initFruits += 1;
          final fruit = Fruit(
              fruit: spawnPoint.name,
              position: spawnPoint.position,
              size: spawnPoint.size);
          add(fruit);
          break;
        case "Saw":
          final isVertical = spawnPoint.properties.getValue("isVertical");
          final offNeg = spawnPoint.properties.getValue("offsetNeg");
          final offPos = spawnPoint.properties.getValue("offsetPos");
          final saw = Saw(
              isVertical: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: spawnPoint.position,
              size: spawnPoint.size);
          add(saw);
          break;
        case "Checkpoint":
          final checkpoint =
              Checkpoint(position: spawnPoint.position, size: spawnPoint.size);
          add(checkpoint);
          break;
        case "Chicken":
          final double offNeg = spawnPoint.properties.getValue("offsetNeg");
          final double offPos = spawnPoint.properties.getValue("offsetPos");
          final chicken = Chicken(
              position: spawnPoint.position,
              size: spawnPoint.size,
              offNeg: offNeg,
              offPos: offPos);
          add(chicken);
          break;
        case "BlueBird":
          final double offNeg = spawnPoint.properties.getValue("offsetNeg");
          final double offPos = spawnPoint.properties.getValue("offsetPos");
          final blueBird = BlueBird(
              position: spawnPoint.position,
              size: spawnPoint.size,
              offNeg: offNeg,
              offPos: offPos);
          add(blueBird);
          break;
        case "Trunk":
          final double offNeg = spawnPoint.properties.getValue("offsetNeg");
          final double offPos = spawnPoint.properties.getValue("offsetPos");
          final trunk = Trunk(
              position: spawnPoint.position,
              size: spawnPoint.size,
              offNeg: offNeg,
              offPos: offPos);
          add(trunk);
          break;
        case "Spikes":
          final spikes =
              Spikes(position: spawnPoint.position, size: spawnPoint.size);
          add(spikes);
          break;
        default:
      }
    }
  }

  void _addCollisions() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>("Collisions");
    for (final collision in collisionLayer!.objects) {
      switch (collision.class_) {
        case "Platform":
          final platform = CollisionBlock(
              position: collision.position,
              size: collision.size,
              isPlatform: true);
          collisionBlocks.add(platform);
          add(platform);
          break;
        default:
          final platform = CollisionBlock(
              position: collision.position, size: collision.size);
          collisionBlocks.add(platform);
          add(platform);
      }
    }
    player.collisionBlocks = collisionBlocks;
  }

  void checkPointReached() async {
    final prefs = await SharedPreferences.getInstance();
    currentStars += 1;
    int currentValue = prefs.getInt("stars_$levelIndex") ?? 0;
    if (currentStars > currentValue) {
      prefs.setInt('stars_$levelIndex', currentStars);
    }
  }
}
