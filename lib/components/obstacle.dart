import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Obstacle extends RectangleComponent with CollisionCallbacks {
  Obstacle({required Vector2 position, required Vector2 size})
      : super(
          position: position,
          size: size,
          paint: Paint()..color = GameConstants.obstacleColor,
        ) {
    // Add hitbox for collisions and raycasting
    add(RectangleHitbox());
  }
}
