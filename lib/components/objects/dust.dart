
import 'package:flame/components.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';

class Dust extends SpriteComponent with HasGameRef<AnotherPixelartPlatformer>{
  Dust({super.position, super.size}){
    sprite = Sprite(game.images.fromCache("Other/Dust Particle.png"));
  }
}