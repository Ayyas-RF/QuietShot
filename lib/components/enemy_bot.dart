import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../game/quiet_shot_game.dart';
import 'bullet.dart';
import 'obstacle.dart';

class EnemyBot extends SpriteComponent with CollisionCallbacks, HasGameReference<QuietShotGame> {
  double health = 100.0;
  int ammo = GameConstants.ammoPerMag;
  Vector2 _lastPosition = Vector2.zero();
  double _reloadTimer = 0.0;
  bool isReloading = false;
  
  double _fireCooldownTimer = 0.0;
  double _patrolTimer = 0.0;
  Vector2 _patrolTarget = Vector2.zero();

  late ShapeHitbox hitbox;
  late final RectangleComponent _healthBar;
  bool isVisibleToPlayer = false;

  EnemyBot({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(GameConstants.playerSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(GameConstants.enemySprite);
    
    // Accurate Hitbox: Slightly smaller than the sprite for better gameplay feel
    hitbox = RectangleHitbox(
      size: size * 0.8,
      position: size * 0.1,
    );
    add(hitbox);

    _healthBar = RectangleComponent(
      position: Vector2(0, -10),
      size: Vector2(GameConstants.playerSize, 5),
      paint: Paint()..color = Colors.green,
    );
    add(_healthBar);
    _setNewPatrolTarget();
  }

  void _setNewPatrolTarget() {
    final random = Random();
    _patrolTarget = Vector2(
      random.nextDouble() * game.size.x, 
      random.nextDouble() * game.size.y
    );
    _patrolTimer = 2.0 + random.nextDouble() * 3.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (health <= 0) return;

    _lastPosition = position.clone();

    _checkVisibility();

    if (_fireCooldownTimer > 0) _fireCooldownTimer -= dt;

    if (isReloading) {
      _reloadTimer -= dt;
      if (_reloadTimer <= 0) {
        ammo = GameConstants.ammoPerMag;
        isReloading = false;
      }
    } else if (ammo == 0) {
      _startReload();
    }

    _aiBehavior(dt);

    // Update health bar visual
    _healthBar.size.x = (health / 100) * GameConstants.playerSize;
    _healthBar.paint.color = health > 50 ? Colors.green : (health > 20 ? Colors.orange : Colors.red);
  }

  void _checkVisibility() {
    final player = game.player;
    final distance = position.distanceTo(player.position);

    // If out of range or behind wall, hidden
    if (distance > GameConstants.fovDistance) {
      isVisibleToPlayer = false;
      return;
    }

    final dirToBot = (position - player.position).normalized();
    final playerDir = Vector2(cos(player.angle), sin(player.angle));
    final angleDiff = acos(dirToBot.dot(playerDir).clamp(-1.0, 1.0));

    if (angleDiff > GameConstants.fovAngle / 2) {
      isVisibleToPlayer = false;
      return;
    }

    final ray = Ray2(origin: player.position, direction: dirToBot);
    final raycastResult = game.collisionDetection.raycast(
      ray,
      maxDistance: distance,
      ignoreHitboxes: [player.hitbox, hitbox],
    );

    isVisibleToPlayer = raycastResult == null || !raycastResult.isActive;
  }

  void _aiBehavior(double dt) {
    final player = game.player;
    final distance = position.distanceTo(player.position);
    
    bool canSeePlayer = false;
    if (distance < 400) {
      final dirToPlayer = (player.position - position).normalized();
      final ray = Ray2(origin: position, direction: dirToPlayer);
      final raycastResult = game.collisionDetection.raycast(
        ray, maxDistance: distance, ignoreHitboxes: [hitbox, player.hitbox]
      );
      if (raycastResult == null || !raycastResult.isActive) {
        canSeePlayer = true;
      }
    }

    if (canSeePlayer) {
      // Aim and attack
      angle = atan2(player.position.y - position.y, player.position.x - position.x);
      if (_fireCooldownTimer <= 0 && !isReloading) {
        _shoot();
      }
    } else {
      // Patrol logic
      _patrolTimer -= dt;
      if (_patrolTimer <= 0 || position.distanceTo(_patrolTarget) < 20) {
        _setNewPatrolTarget();
      }
      
      final dir = (_patrolTarget - position).normalized();
      angle = lerpDouble(angle, atan2(dir.y, dir.x), 0.1) ?? angle;
      position += dir * GameConstants.botSpeed * dt;
    }
  }

  void _startReload() {
    isReloading = true;
    _reloadTimer = GameConstants.reloadTime;
  }

  void _shoot() {
    if (isReloading || ammo <= 0 || _fireCooldownTimer > 0 || health <= 0) return;

    ammo -= 1;
    _fireCooldownTimer = GameConstants.fireCooldown;

    Vector2 fireDirection = Vector2(cos(angle), sin(angle));
    Vector2 spawnPos = position + fireDirection * (GameConstants.playerSize / 2);
    
    game.add(Bullet(
      position: spawnPos,
      direction: fireDirection,
      isPlayerBullet: false,
    ));
  }

  @override
  void render(Canvas canvas) {
    if (!isVisibleToPlayer) return;
    super.render(canvas);
  }

  @override
  void renderTree(Canvas canvas) {
     if (!isVisibleToPlayer) return;
     super.renderTree(canvas);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Bullet && other.isPlayerBullet) {
      health -= 25;
      other.removeFromParent();
      if (health <= 0) {
        health = 0;
        game.onBotDied();
      }
    }

    if (other is Obstacle) {
      position = _lastPosition;
    }
  }
}
