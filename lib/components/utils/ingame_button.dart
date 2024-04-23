
import 'dart:async';

import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class IngameButton extends SpriteComponent with HasGameReference<AnotherPixelartPlatformer>, TapCallbacks, ComponentViewportMargin{
  final Function callback;
  final String imagePath;
  final EdgeInsets buttonMargin;
  IngameButton({required this.callback, required this.imagePath, required this.buttonMargin});

  @override
  FutureOr<void> onLoad() {
    margin = buttonMargin;
    priority = 10;
    sprite = Sprite(game.images.fromCache(imagePath));
    size = Vector2.all(32);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    callback();
    super.onTapDown(event);
  }
}