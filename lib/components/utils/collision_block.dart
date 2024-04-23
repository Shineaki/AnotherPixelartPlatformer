import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;

  CollisionBlock({super.position, super.size, this.isPlatform = false}) {
    add(RectangleHitbox(
        position: Vector2.zero(), size: size, collisionType: CollisionType.passive));
  }
}
