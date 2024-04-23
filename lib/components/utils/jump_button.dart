import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';

class JumpButton extends SpriteComponent
    with
        HasGameReference<AnotherPixelartPlatformer>,
        TapCallbacks,
        ComponentViewportMargin {
  final double buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    margin = const EdgeInsets.only(right: 1, bottom: 16);
    priority = 10;
    sprite = Sprite(game.images.fromCache("HUD/JumpButton.png"));
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
