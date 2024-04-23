import 'dart:async';
import 'dart:ui';

import 'package:another_pixelart_platformer/components/objects/my_object_mixins.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:another_pixelart_platformer/components/player.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';

class BlueBird extends SpriteAnimationComponent
    with
        HasGameRef<AnotherPixelartPlatformer>,
        CollisionCallbacks,
        VelocityMixin,
        CanDieMixin {
  static const double bounceHeight = 300;
  final double offNeg;
  final double offPos;
  final double stepTime = 0.05;
  BlueBird({super.position, super.size, this.offNeg = 0, this.offPos = 0});

  final Vector2 textureSize = Vector2(32, 34);
  late RectangleHitbox hitbox;

  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  double runSpeed = 50;
  bool gotStomped = false;

  late final Player player;

  @override
  FutureOr<void> onLoad() {

    animation = _createAnimation("Flying", 9);
    hitbox = RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 20));
    add(hitbox);
    _calculateRange();
    player = game.player;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (gotStomped) {
      die(dt);
    } else {
      _updateState();
      _movement(dt);
    }

    super.update(dt);
  }

  SpriteAnimation _createAnimation(String stateName, int frameAmount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/BlueBird/$stateName (32x32).png"),
      SpriteAnimationData.sequenced(
          amount: frameAmount, stepTime: stepTime, textureSize: textureSize),
    );
  }

  void _calculateRange() {
    var tileSize = 16;
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void _movement(double dt) {
    if (position.x + targetDirection * runSpeed * dt > rangePos ||
        position.x + targetDirection * runSpeed * dt < rangeNeg) {
      targetDirection *= -1;
    }
    velocity.x = targetDirection * runSpeed;

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt;
  }

  void _updateState() {
    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() {
    if (player.velocity.y > 0 && player.y < position.y) {
      if (game.playSounds) {
        FlameAudio.play("bounce.wav", volume: game.soundVolume);
      }
      gotStomped = true;
      animation = _createAnimation("Hit", 5)..loop = false;
      remove(hitbox);
      velocity.y = -250;
      player.velocity.y = -bounceHeight;
    } else {
      player.collideWithEnemy();
    }
  }
}
