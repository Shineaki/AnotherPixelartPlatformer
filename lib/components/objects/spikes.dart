import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';

class Spikes extends SpriteComponent
    with HasGameRef<AnotherPixelartPlatformer>, CollisionCallbacks {
  Spikes({super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache("Traps/Spikes/Idle.png"));
    add(RectangleHitbox(position: Vector2(0,8), size: Vector2(16, 8)));
    return super.onLoad();
  }
}
