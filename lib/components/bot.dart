import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../game/quiet_shot_game.dart';
import 'bullet.dart';

class Bot extends RectangleComponent with CollisionCallbacks, HasGameRef<QuietShotGame> {
  double health = 100.0;
  int ammo = GameConstants.ammoPerMag;
  
  double _reloadTimer = 0.0;
  bool isReloading = false;
  
  double _fireCooldownTimer = 0.0;
  double _patrolTimer = 0.0;
  Vector2 _patrolTarget = Vector2.zero();

  late RectangleHitbox hitbox;
  late final RectangleComponent _healthBar;
  bool isVisibleToPlayer = true;

  Bot({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(GameConstants.playerSize),
          anchor: Anchor.center,
          paint: Paint()..color = GameConstants.botColor,
        ) {
    hitbox = RectangleHitbox();
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
    // Assuming 800x600, game limits
    _patrolTarget = Vector2(random.nextDouble() * 800, random.nextDouble() * 600);
    _patrolTimer = 3.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (health <= 0) return;

    _checkVisibility();

    if (_fireCooldownTimer > 0) _fireCooldownTimer -= dt;

    if (isReloading) {
      _reloadTimer -= dt;
      if (_reloadTimer <= 0) {
        ammo = GameConstants.ammoPerMag;
        isReloading = false;
        gameRef.hudNotifier.value = gameRef.hudNotifier.value.copyWith(botAmmo: ammo);
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
    final player = gameRef.player;
    final distance = position.distanceTo(player.position);

    if (distance > GameConstants.fovDistance) {
      isVisibleToPlayer = false;
      return;
    }

    // Check angle
    final dirToBot = (position - player.position).normalized();
    final playerDir = Vector2(cos(player.angle), sin(player.angle));
    final dotProduct = dirToBot.dot(playerDir);
    final angleDiff = acos(dotProduct.clamp(-1.0, 1.0));

    if (angleDiff > GameConstants.fovAngle / 2) {
      isVisibleToPlayer = false;
      return;
    }

    // Check Line of Sight (Raycast)
    final ray = Ray2(origin: player.position, direction: dirToBot);
    final raycastResult = gameRef.collisionDetection.raycast(
      ray,
      maxDistance: distance,
      ignoreHitboxes: [player.hitbox, hitbox], // ignore player and bot hitboxes
    );

    // If it hit something before the bot, it's blocked by an obstacle
    if (raycastResult != null && raycastResult.isActive) {
      isVisibleToPlayer = false;
    } else {
      isVisibleToPlayer = true;
    }
  }

  void _aiBehavior(double dt) {
    final player = gameRef.player;
    final distance = position.distanceTo(player.position);
    
    // Simple state: If can see player, aim and shoot. Else patrol.
    bool canSeePlayer = false;
    
    // AI sight check is simpler, just distance and raycast
    if (distance < 500) {
      final dirToPlayer = (player.position - position).normalized();
      final ray = Ray2(origin: position, direction: dirToPlayer);
      final raycastResult = gameRef.collisionDetection.raycast(
        ray, maxDistance: distance, ignoreHitboxes: [hitbox, player.hitbox]
      );
      if (raycastResult == null || !raycastResult.isActive) {
        canSeePlayer = true;
      }
    }

    if (canSeePlayer) {
      // Aim at player
      angle = atan2(player.position.y - position.y, player.position.x - position.x);
      
      // Stop moving and shoot
      if (_fireCooldownTimer <= 0 && !isReloading) {
        _shoot();
      }
    } else {
      // Patrol
      _patrolTimer -= dt;
      if (_patrolTimer <= 0 || position.distanceTo(_patrolTarget) < 10) {
        _setNewPatrolTarget();
      }
      
      final dir = (_patrolTarget - position).normalized();
      angle = atan2(dir.y, dir.x);
      position += dir * GameConstants.botSpeed * dt;

      position.x = position.x.clamp(0, gameRef.size.x);
      position.y = position.y.clamp(0, gameRef.size.y);
    }
  }

  void _startReload() {
    isReloading = true;
    _reloadTimer = GameConstants.reloadTime;
    gameRef.hudNotifier.value = gameRef.hudNotifier.value.copyWith(botReloading: true);
  }

  void _shoot() {
    if (isReloading || ammo <= 0 || _fireCooldownTimer > 0 || health <= 0) return;

    ammo -= 1;
    _fireCooldownTimer = GameConstants.fireCooldown;
    gameRef.hudNotifier.value = gameRef.hudNotifier.value.copyWith(botAmmo: ammo);

    Vector2 fireDirection = Vector2(cos(angle), sin(angle));
    Vector2 spawnPos = position + fireDirection * (GameConstants.playerSize);
    
    gameRef.add(Bullet(
      position: spawnPos,
      direction: fireDirection,
      isPlayerBullet: false,
    ));

    if (ammo == 0) {
      _startReload();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isVisibleToPlayer) return;
    super.render(canvas);
  }

  @override
  void renderTree(Canvas canvas) {
     if (!isVisibleToPlayer) return; // Hide bot and its health bar if not visible
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
        gameRef.onBotDied();
      }
    }
  }
}
