import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../game/quiet_shot_game.dart';
import 'bullet.dart';
import 'fov_cone.dart';

class Player extends SpriteComponent
    with KeyboardHandler, CollisionCallbacks, HasGameRef<QuietShotGame> {
  Vector2 _movement = Vector2.zero();
  double _rotationSpeed = 0.0;
  
  double health = 100.0;
  int ammo = GameConstants.ammoPerMag;
  
  double _reloadTimer = 0.0;
  bool isReloading = false;
  
  double _fireCooldownTimer = 0.0;

  late RectangleHitbox hitbox;
  late final RectangleComponent _healthBar;

  Player({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(GameConstants.playerSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(GameConstants.playerSprite);
    
    // Proper Hitbox: Slightly smaller than sprite for tighter gameplay
    hitbox = RectangleHitbox(
      size: size * 0.8,
      position: size * 0.1,
    );
    add(hitbox);
    add(FOVCone());

    // Health bar representation
    _healthBar = RectangleComponent(
      position: Vector2(0, -10),
      size: Vector2(GameConstants.playerSize, 5),
      paint: Paint()..color = Colors.green,
    );
    add(_healthBar);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _movement.x = 0;
    _movement.y = 0;
    _rotationSpeed = 0.0;

    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _movement.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _movement.x += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      _movement.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      _movement.y += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyQ)) {
      _rotationSpeed = -3.0;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
      _rotationSpeed = 3.0;
    }

    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      shoot();
    }

    if (_movement.length > 0) {
      _movement = _movement.normalized();
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (health <= 0) return;

    // Movement
    position += _movement * GameConstants.playerSpeed * dt;

    // Keep within world bounds (assume 800x600 for now, override later if game has camera)
    position.x = position.x.clamp(0, gameRef.size.x);
    position.y = position.y.clamp(0, gameRef.size.y);

    // Aiming
    angle += _rotationSpeed * dt;

    // Shooting timers
    if (_fireCooldownTimer > 0) {
      _fireCooldownTimer -= dt;
    }

    // Reloading
    if (isReloading) {
      _reloadTimer -= dt;
      if (_reloadTimer <= 0) {
        ammo = GameConstants.ammoPerMag;
        isReloading = false;
        gameRef.hudNotifier.value = gameRef.hudNotifier.value.copyWith(playerAmmo: ammo);
      }
    } else if (ammo == 0) {
      _startReload();
    }
    
    // Update health bar visual
    _healthBar.size.x = (health / 100) * GameConstants.playerSize;
    _healthBar.paint.color = health > 50 ? Colors.green : (health > 20 ? Colors.orange : Colors.red);
  }

  void _startReload() {
    isReloading = true;
    _reloadTimer = GameConstants.reloadTime;
    gameRef.hudNotifier.value = gameRef.hudNotifier.value.copyWith(playerReloading: true);
  }

  void shoot() {
    if (isReloading || ammo <= 0 || _fireCooldownTimer > 0 || health <= 0) return;

    ammo -= 1;
    _fireCooldownTimer = GameConstants.fireCooldown;
    gameRef.hudNotifier.value = gameRef.hudNotifier.value.copyWith(playerAmmo: ammo);

    Vector2 fireDirection = Vector2(cos(angle), sin(angle));
    // Spawn bullet slightly in front to avoid shooting self
    Vector2 spawnPos = position + fireDirection * (GameConstants.playerSize);
    
    gameRef.add(Bullet(
      position: spawnPos,
      direction: fireDirection,
      isPlayerBullet: true,
    ));

    if (ammo == 0) {
      _startReload();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Bullet && !other.isPlayerBullet) {
      health -= 25; // Proper damage
      other.removeFromParent();
      if (health <= 0) {
        health = 0;
        gameRef.onPlayerDied();
      }
    }
  }
}
