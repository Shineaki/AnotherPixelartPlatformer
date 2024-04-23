import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';
import 'package:flame/components.dart';

mixin VelocityMixin {
  Vector2 velocity = Vector2.zero();
  final double _gravity = 900;
}

mixin CanDieMixin
    on VelocityMixin, PositionComponent, HasGameRef<AnotherPixelartPlatformer> {
  void die(double dt) {
    if (scale.x > 0) {
      if (angle < 3.14) {
        angle += 3 * dt;
      }
    } else {
      if (angle > -3.14) {
        angle -= 3 * dt;
      }
    }
    velocity.y += _gravity * dt;
    velocity.y = velocity.y.clamp(-200, 500);
    position.y += velocity.y * dt;
    if (position.y > game.canvasSize.y) {
      removeFromParent();
    }
  }
}
