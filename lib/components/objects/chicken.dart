import 'dart:async';
import 'dart:ui';

import 'package:another_pixelart_platformer/components/objects/my_object_mixins.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:another_pixelart_platformer/components/player.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';

enum State { idle, run, hit }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<AnotherPixelartPlatformer>, CollisionCallbacks, VelocityMixin, CanDieMixin {
  static const double bounceHeight = 300;
  final double offNeg;
  final double offPos;
  final double stepTime = 0.05;
  Chicken({super.position, super.size, this.offNeg = 0, this.offPos = 0});

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _hitAnimation;
  late final SpriteAnimation _runAnimation;
  final Vector2 textureSize = Vector2(32, 34);
  late RectangleHitbox hitbox;

  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  double runSpeed = 120;
  bool gotStomped = false;

  late final Player player;

  @override
  FutureOr<void> onLoad() {

    hitbox = RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26));
    add(hitbox);
    _loadAllAnimations();
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

  void _loadAllAnimations() {
    _idleAnimation = _createAnimation("Idle", 13);
    _hitAnimation = _createAnimation("Hit", 5)..loop = false;
    _runAnimation = _createAnimation("Run", 14);

    animations = {
      State.idle: _idleAnimation,
      State.hit: _hitAnimation,
      State.run: _runAnimation
    };

    current = State.idle;
  }

  SpriteAnimation _createAnimation(String stateName, int frameAmount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Chicken/$stateName (32x34).png"),
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
    velocity.x = 0;

    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double chickenOffset = (scale.x > 0) ? 0 : -width;

    if (playerInRange()) {
      targetDirection =
          (player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * runSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt;
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void _updateState() {
    current = (velocity.x != 0) ? State.run : State.idle;
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
      current = State.hit;
      remove(hitbox);
      velocity.y = -250;
      player.velocity.y = -bounceHeight;
    } else {
      player.collideWithEnemy();
    }
  }
}
