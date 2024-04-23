import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:another_pixelart_platformer/components/player.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<AnotherPixelartPlatformer>, CollisionCallbacks {
  Checkpoint({super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
        position: Vector2(18, 56),
        size: Vector2(12, 8),
        collisionType: CollisionType.passive));
    animation = SpriteAnimation.fromFrameData(
        game.images
            .fromCache("Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png"),
        SpriteAnimationData.sequenced(
            amount: 1, stepTime: 1, textureSize: Vector2.all(64)));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _reachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() {
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache(
            "Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png"),
        SpriteAnimationData.sequenced(
            loop: false,
            amount: 26,
            stepTime: 0.02,
            textureSize: Vector2.all(64)));
    animationTicker?.onComplete = () {
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache(
              "Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png"),
          SpriteAnimationData.sequenced(
              amount: 10, stepTime: 0.05, textureSize: Vector2.all(64)));
    };
  }
}
