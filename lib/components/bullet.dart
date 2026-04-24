import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'obstacle.dart';
import '../game/quiet_shot_game.dart';

class Bullet extends CircleComponent with CollisionCallbacks, HasGameReference<QuietShotGame> {
  final Vector2 direction;
  final bool isPlayerBullet;

  Bullet({
    required Vector2 position,
    required this.direction,
    required this.isPlayerBullet,
  }) : super(
          position: position,
          radius: 4,
          anchor: Anchor.center,
          paint: Paint()..color = isPlayerBullet ? Colors.yellowAccent : Colors.orangeAccent,
        ) {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * GameConstants.bulletSpeed * dt;

    // Remove if it goes way off screen
    if (position.x < -100 || position.y < -100 || 
        position.x > game.size.x + 100 || position.y > game.size.y + 100) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    // Destroy on obstacle
    if (other is Obstacle) {
      removeFromParent();
    }
    // Note: Collision with Player/Bot is handled in their respective classes to deduct health.
  }
}
