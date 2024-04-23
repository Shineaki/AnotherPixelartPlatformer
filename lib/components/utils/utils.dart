import 'package:another_pixelart_platformer/components/utils/collision_block.dart';
import 'package:another_pixelart_platformer/components/player.dart';
import 'package:flame/components.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final playerX = player.position.x + player.hitBox.offset.x;
  final playerY = player.position.y + player.hitBox.offset.y;
  final playerW = player.hitBox.size.x;
  final playerH = player.hitBox.size.y;

  final blockX = block.x;
  final blockY = block.y;
  final blockW = block.width;
  final blockH = block.height;

  final fixedX = player.scale.x < 0
      ? playerX - (player.hitBox.offset.x * 2) - playerW
      : playerX;
  final fixedY = block.isPlatform ? playerY + playerH : playerY;

  return (fixedY < blockY + blockH &&
      playerY + playerH > blockY &&
      fixedX < blockX + blockW &&
      fixedX + playerW > blockX);
}

bool checkTouching(Player player, CollisionBlock block) {
  Vector2 slideCheckPoint = player.scale.x > 0
      ? Vector2(
          player.position.x + player.hitBox.offset.x + player.hitBox.size.x + 2,
          player.position.y + player.hitBox.offset.y + player.hitBox.size.y / 2)
      : Vector2(
          player.position.x - player.hitBox.offset.x - player.hitBox.size.x - 2,
          player.position.y +
              player.hitBox.offset.y +
              player.hitBox.size.y / 2);

  return (slideCheckPoint.y < block.y + block.height &&
      slideCheckPoint.y > block.y &&
      slideCheckPoint.x < block.x + block.width &&
      slideCheckPoint.x > block.x);

}
