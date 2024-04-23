import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:another_pixelart_platformer/components/utils/custom_hitbox.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<AnotherPixelartPlatformer>, CollisionCallbacks {
  final String fruit;
  Fruit({super.position, super.size, this.fruit = "Apple"});
  final double stepTime = 0.025;
  final hitbox = CustomHitbox(offset: Vector2(10, 10), size: Vector2(12, 12));
  bool collected = false;

  @override
  FutureOr<void> onLoad() {
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache("Items/Fruits/$fruit.png"),
        SpriteAnimationData.sequenced(
            amount: 17, stepTime: stepTime, textureSize: Vector2.all(32)));
    add(RectangleHitbox(
        position: hitbox.offset,
        size: hitbox.size,
        collisionType: CollisionType.passive));

    return super.onLoad();
  }

  void collisionWithPlayer() {
    if (!collected) {
      game.myWorld.fruitCollected();
      collected = true;
      if (game.playSounds) {
        FlameAudio.play("pickup.wav", volume: game.soundVolume);
      }
      removeOnFinish = true;
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache("Items/Fruits/Collected.png"),
          SpriteAnimationData.sequenced(
              amount: 6,
              stepTime: stepTime,
              textureSize: Vector2.all(32),
              loop: false));
    }
  }
}
