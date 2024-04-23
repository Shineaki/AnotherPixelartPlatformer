import 'dart:async';
import 'dart:math';
import 'package:another_pixelart_platformer/components/objects/blue_bird.dart';
import 'package:another_pixelart_platformer/components/objects/trunk.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:another_pixelart_platformer/components/objects/checkpoint.dart';
import 'package:another_pixelart_platformer/components/objects/chicken.dart';
import 'package:another_pixelart_platformer/components/utils/collision_block.dart';
import 'package:another_pixelart_platformer/components/utils/custom_hitbox.dart';
import 'package:another_pixelart_platformer/components/objects/fruit.dart';
import 'package:another_pixelart_platformer/components/objects/saw.dart';
import 'package:another_pixelart_platformer/components/objects/spikes.dart';
import 'package:another_pixelart_platformer/components/utils/utils.dart';
import 'package:another_pixelart_platformer/another_pixelart_platformer.dart';

enum PlayerState {
  idle,
  running,
  jumping,
  doubleJumping,
  falling,
  sliding,
  hit,
  spawn,
  despawn
}

class Player extends SpriteAnimationGroupComponent
    with
        HasGameRef<AnotherPixelartPlatformer>,
        KeyboardHandler,
        CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation doubleJumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation slidingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation spawnAnimation;
  late final SpriteAnimation despawnAnimation;

  bool started = false;
  final double stepTime = 0.05;
  String character;
  bool isFacingRight = true;
  double particleTimer = 0.0;

  final double _gravity = 900;
  final double _slideGravity = 50;
  final double _jumpForce = 250;
  final double _terminalVelocity = 500;
  double horizontalMovement = 0;
  double moveSpeed = 100.0;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool isSliding = false;
  bool hasJumped = false;
  int maxJumps = 2;
  int currentJumps = 0;
  bool slidingJumpReseted = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  Vector2 startingPosition = Vector2.all(0);

  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitBox =
      CustomHitbox(offset: Vector2(10, 4), size: Vector2(14, 28));

  Player({super.position, this.character = "Virtual Guy"});

  @override
  FutureOr<void> onLoad() {

    startingPosition = Vector2(position.x, position.y);
    _onLoadAllAnimations();
    add(RectangleHitbox(position: hitBox.offset, size: hitBox.size));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (started && !gotHit && !reachedCheckpoint) {
      _updatePlayerMovement(dt);
      _updatePlayerState();
      _checkHorizontalCollision();
      _applyGravity(dt);
      _checkVerticalCollision();
    }
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    horizontalMovement = isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) {
        other.collisionWithPlayer();
      }
      if (other is Saw || other is Spikes) {
        _respawn();
      }
      if (other is Chicken) {
        other.collidedWithPlayer();
      }
      if ( other is BlueBird){
        other.collidedWithPlayer();
      }
      if (other is Trunk) {
        other.collidedWithPlayer();
      }
      if (other is Checkpoint && !reachedCheckpoint) {
        _reachedCheckpoint();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _onLoadAllAnimations() {
    idleAnimation = _spriteAnimation("Idle", 11);
    runningAnimation = _spriteAnimation("Run", 12);
    jumpingAnimation = _spriteAnimation("Jump", 1);
    doubleJumpingAnimation = _spriteAnimation("Double Jump", 6, sTime: .03);
    fallingAnimation = _spriteAnimation("Fall", 1);
    slidingAnimation = _spriteAnimation("Wall Jump", 5);
    hitAnimation = _spriteAnimation("Hit", 7);
    spawnAnimation = _specialSpriteAnimation("Appearing", 7);
    despawnAnimation = _specialSpriteAnimation("Desappearing", 7);

    // List all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.doubleJumping: doubleJumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.sliding: slidingAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.spawn: spawnAnimation,
      PlayerState.despawn: despawnAnimation,
    };

    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String stateName, int frameAmount,
      {double sTime = -1.0}) {
    return SpriteAnimation.fromFrameData(
        game.images
            .fromCache("Main Characters/$character/$stateName (32x32).png"),
        SpriteAnimationData.sequenced(
            amount: frameAmount,
            stepTime: sTime < 0 ? stepTime : sTime,
            textureSize: Vector2.all(32)));
  }

  SpriteAnimation _specialSpriteAnimation(String stateName, int frameAmount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache("Main Characters/$stateName (96x96).png"),
        SpriteAnimationData.sequenced(
            loop: false,
            amount: frameAmount,
            stepTime: stepTime,
            textureSize: Vector2.all(96)));
  }

  void _updatePlayerMovement(double dt) {
    if ((hasJumped && isOnGround) || (hasJumped && !isOnGround)) {
      _playerJump(dt);
    }
    _addParticle(dt);
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.y > 0) {
      isSliding = _checkSliding();
      if (isSliding && currentJumps > 0 && !slidingJumpReseted){
        currentJumps = 1;
        slidingJumpReseted = true;
      }
      if (isSliding) {
        playerState = PlayerState.sliding;
      } else {
        playerState = PlayerState.falling;
      }
    }

    if (velocity.y < 0) {
      if (currentJumps > 1) {
        playerState = PlayerState.doubleJumping;
      } else {
        playerState = PlayerState.jumping;
      }
    }

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
      isFacingRight = false;
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
      isFacingRight = true;
    }

    if ((velocity.x > 0 || velocity.x < 0) && isOnGround) {
      playerState = PlayerState.running;
    }

    current = playerState;
  }

  void _playerJump(double dt) {
    if (currentJumps < maxJumps) {
      if (game.playSounds) {
        FlameAudio.play("jump.wav", volume: game.soundVolume);
      }
      currentJumps += 1;
      velocity.y = -_jumpForce;
      position.y += velocity.y * dt;
      isOnGround = false;
      hasJumped = false;
    }
  }

  bool _checkSliding() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkTouching(this, block)) {
          return true;
        }
      }
    }
    return false;
  }

  void _checkHorizontalCollision() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.position.x - hitBox.offset.x - hitBox.size.x;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.position.x + block.width + hitBox.offset.x  + hitBox.size.x;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    if (current == PlayerState.sliding) {
      velocity.y += _slideGravity * dt;
    } else {
      velocity.y += _gravity * dt;
    }
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollision() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitBox.size.y - hitBox.offset.y;
            isOnGround = true;
            currentJumps = 0;
            slidingJumpReseted = false;
            isSliding = false;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitBox.size.y - hitBox.offset.y;
            isOnGround = true;
            currentJumps = 0;
            slidingJumpReseted = false;
            isSliding = false;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitBox.offset.y; //TODO
            break;
          }
        }
      }
    }
  }

  void _respawn() {
    if (game.playSounds) {
      FlameAudio.play("hit.wav", volume: game.soundVolume);
    }
    gotHit = true;
    current = PlayerState.hit;
    Future.delayed(const Duration(milliseconds: 350), () {
      scale.x = 1;
      position = startingPosition - Vector2.all(32);
      current = PlayerState.spawn;
      isFacingRight = true;
      Future.delayed(const Duration(milliseconds: 350), () {
        velocity = Vector2.zero();
        position = startingPosition;
        _updatePlayerState();
        Future.delayed(const Duration(milliseconds: 400), () {
          gotHit = false;
        });
      });
    });
  }

  void _reachedCheckpoint() {
    if (game.playSounds) {
      FlameAudio.play("checkpoint.wav", volume: game.soundVolume);
    }
    game.myWorld.checkPointReached();
    reachedCheckpoint = true;
    if (scale.x > 0) {
      position = position - Vector2.all(32);
    } else {
      position = position + Vector2(32, -32);
    }
    current = PlayerState.despawn;
    animationTicker?.onComplete = () {
      position = Vector2.all(-640);
      reachedCheckpoint = false;
      Future.delayed(const Duration(seconds: 1), () {
        game.loadNextLevel();
      });
    };
  }

  void collideWithEnemy() {
    _respawn();
  }

  void _addParticle(double dt) {
    int maxCount = 5;
    double particleSize = 8;
    double particleTimeout = 0.5;
    double maxLifeSpan = 0.2;
    double xSpeed = 1000;
    double ySpeed = -500;
    double xPosition = position.x + (scale.x > 0 ? width / 2 : -width / 2);
    double yPosition = position.y + height - particleSize / 2;

    particleTimer += dt;
    if ((isOnGround && (velocity.x > 0.0 || velocity.x < 0.0)) &&
        particleTimer > particleTimeout) {
      particleTimer = 0;
      var particle = ParticleSystemComponent(
          particle: Particle.generate(
              lifespan: Random().nextDouble() * maxLifeSpan + 0.1,
              count: Random().nextInt(maxCount),
              generator: (i) => AcceleratedParticle(
                  position: Vector2(xPosition, yPosition),
                  acceleration: Vector2(
                      Random().nextDouble() * xSpeed * (-horizontalMovement),
                      Random().nextDouble() * ySpeed),
                  child: SpriteParticle(
                      sprite: Sprite(
                          game.images.fromCache("Other/Dust Particle.png"),
                          srcSize: Vector2.all(particleSize))))));
      particle.addToParent(parent!);
    }
  }
}
