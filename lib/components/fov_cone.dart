import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../game/quiet_shot_game.dart';

import 'package:flame/collisions.dart';
import 'bullet.dart';

class FOVCone extends PositionComponent with HasGameReference<QuietShotGame> {
  final Paint _paint;
  final List<Vector2> _polygonVertices = [];

  FOVCone()
      : _paint = Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill,
        super(anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _castRays();
  }

  void _castRays() {
    _polygonVertices.clear();
    // Add origin of the cone (the player's center)
    _polygonVertices.add(Vector2.zero());

    double halfFov = GameConstants.fovAngle / 2;
    double startAngle = -halfFov;
    double step = GameConstants.fovAngle / GameConstants.rayCount;

    // Cast rays in a fan
    for (int i = 0; i <= GameConstants.rayCount; i++) {
      double rayAngle = startAngle + (i * step);
      
      // Global direction based on parent's (player's) angle + rayAngle
      // Parent's angle is managed by player but the local cone thinks of itself facing 0
      // Actually, since this component rotates WITH the parent, its local 0 angle is forward.
      // But we need global coordinates for raycasting.
      double globalAngle = (parent as PositionComponent).angle + rayAngle;
      Vector2 direction = Vector2(cos(globalAngle), sin(globalAngle));
      Vector2 origin = (parent as PositionComponent).position;

      Ray2 ray = Ray2(origin: origin, direction: direction);
      
      // Ignore self, player children (hitboxes), and ALL bullets in the game
      final ignoreList = (parent as PositionComponent).children.whereType<ShapeHitbox>().toList();
      ignoreList.addAll(game.children.whereType<Bullet>().expand((b) => b.children.whereType<ShapeHitbox>()));

      final raycastResult = game.collisionDetection.raycast(
        ray,
        maxDistance: GameConstants.fovDistance,
        ignoreHitboxes: ignoreList,
      );

      Vector2 hitPoint;
      if (raycastResult != null && raycastResult.isActive) {
        hitPoint = raycastResult.intersectionPoint!;
      } else {
        hitPoint = origin + direction * GameConstants.fovDistance;
      }

      // Convert global hitPoint back to local coordinates for drawing the polygon
      // local_point = (hitPoint - origin).rotated(-parent.angle)
      Vector2 localPoint = (hitPoint - origin)..rotate(-(parent as PositionComponent).angle);
      _polygonVertices.add(localPoint);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_polygonVertices.length < 3) return;

    var path = Path();
    path.moveTo(_polygonVertices[0].x, _polygonVertices[0].y);
    for (int i = 1; i < _polygonVertices.length; i++) {
      path.lineTo(_polygonVertices[i].x, _polygonVertices[i].y);
    }
    path.close();

    // Tactical Flashlight Gradient
    _paint.shader = ui.Gradient.radial(
      Offset.zero,
      GameConstants.fovDistance,
      [
        Colors.yellow.withValues(alpha: 0.3),
        Colors.yellow.withValues(alpha: 0.1),
        Colors.transparent,
      ],
      [0.0, 0.6, 1.0],
    );

    canvas.drawPath(path, _paint);
  }
}
