import 'dart:async';

import 'package:another_pixelart_platformer/components/objects/trunk.dart';
import 'package:another_pixelart_platformer/components/player.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Bullet extends SpriteComponent
    with HasGameReference<AnotherPixelartPlatformer>, CollisionCallbacks {
  final double direction;
  Bullet({super.position, required this.direction}) {
    size = Vector2.all(16);
    scale.x = direction;
  }

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache("Enemies/Trunk/Bullet.png"));
    add(CircleHitbox(position: Vector2(4, 4), radius: 4));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.x += direction * 200 * dt;
    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Trunk) {
      return;
    }
    if (other is Player) {
      other.collideWithEnemy();
    }
    removeFromParent();
  }
}
