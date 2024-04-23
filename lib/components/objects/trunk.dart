import 'dart:async';
import 'dart:ui';

import 'package:another_pixelart_platformer/components/objects/bullet.dart';
import 'package:another_pixelart_platformer/components/objects/my_object_mixins.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:another_pixelart_platformer/components/player.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';

enum State { idle, run, hit, attack }

class Trunk extends SpriteAnimationGroupComponent
    with
        HasGameRef<AnotherPixelartPlatformer>,
        CollisionCallbacks,
        VelocityMixin,
        CanDieMixin {
  static const double bounceHeight = 300;
  final double offNeg;
  final double offPos;
  final double stepTime = 0.05;
  Trunk({super.position, super.size, this.offNeg = 0, this.offPos = 0});

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _hitAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _attackAnimation;
  final Vector2 textureSize = Vector2(64, 32);
  late RectangleHitbox hitbox;

  double shootTimeout = 0.55;
  double shootTimer = 0.0;
  double moveRangeNeg = 0;
  double attackRangeNeg = 0;
  double moveRangePos = 0;
  double attackRangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  double runSpeed = 30;
  bool gotStomped = false;

  late final Player player;

  @override
  FutureOr<void> onLoad() {
    hitbox = RectangleHitbox(position: Vector2(20, 6), size: Vector2(24, 26));
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
    _idleAnimation = _createAnimation("Idle", 18);
    _hitAnimation = _createAnimation("Hit", 5)..loop = false;
    _runAnimation = _createAnimation("Run", 14);
    _attackAnimation = _createAnimation("Attack", 11);

    animations = {
      State.idle: _idleAnimation,
      State.hit: _hitAnimation,
      State.run: _runAnimation,
      State.attack: _attackAnimation
    };

    current = State.idle;
  }

  SpriteAnimation _createAnimation(String stateName, int frameAmount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Trunk/$stateName (64x32).png"),
      SpriteAnimationData.sequenced(
          amount: frameAmount, stepTime: stepTime, textureSize: textureSize),
    );
  }

  void _calculateRange() {
    var tileSize = 16;
    moveRangeNeg = position.x + width / 2 - offNeg * tileSize;
    attackRangeNeg = moveRangeNeg - tileSize;
    moveRangePos = position.x + width / 2 + offPos * tileSize;
    attackRangePos = moveRangePos + tileSize;
  }

  void _movement(double dt) {
    shootTimer += dt;
    velocity.x = 0;

    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double trunkOffset = (scale.x > 0) ? 0 : -width;

    if (playerInRange()) {
      targetDirection =
          (player.x + playerOffset < position.x + trunkOffset) ? -1 : 1;
      if (shootTimer >= shootTimeout) {
        shootTimer = 0.0;
        _attack(dt);
      }
    } else {
      if (position.x + targetDirection * runSpeed * dt > moveRangePos ||
          position.x + targetDirection * runSpeed * dt < moveRangeNeg) {
        targetDirection *= -1;
      }
      velocity.x = targetDirection * runSpeed;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;

    position.x += velocity.x * dt;
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;

    if (targetDirection < 0) {
      return player.x + playerOffset >= attackRangeNeg &&
          player.x + playerOffset <= position.x + width/2 &&
          player.y + player.height > position.y &&
          player.y < position.y + height;
    } else {
      return player.x + playerOffset >= position.x - width/2 &&
        player.x + playerOffset <= attackRangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
    }
  }

  void _updateState() {
    if (playerInRange()) {
      current = State.attack;
    } else {
      current = State.run;
    }
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
      player.isOnGround = false;
    } else {
      player.collideWithEnemy();
    }
  }

  void _attack(double dt) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!gotStomped && playerInRange()) {
        double trunkOffset = (scale.x > 0) ? 0 : -width;
        Bullet bullet = Bullet(
            position: Vector2(position.x + trunkOffset + 32, position.y + 12),
            direction: -scale.x);
        parent!.add(bullet);
      }
    });
  }
}
