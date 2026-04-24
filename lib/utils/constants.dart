import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameConstants {
  static const double playerSpeed = 150.0;
  static const double botSpeed = 100.0;
  static const double bulletSpeed = 500.0;
  
  static const double obstacleSize = 64.0;
  static const double playerSize = 32.0;

  static const double fovDistance = 350.0;
  static const double fovAngle = 1.0; // Radians, approx 57/2 = 28 degrees on each side? Wait, 1.0 is ~57 degrees total. Let's make it 1.2.
  static const int rayCount = 60; // Accuracy of FOV

  static const int ammoPerMag = 10;
  static const double reloadTime = 2.0;
  static const double fireCooldown = 0.3;

  static const Color playerColor = Colors.blueAccent;
  static const Color botColor = Colors.redAccent;
  static const Color obstacleColor = Color.fromARGB(255, 60, 60, 60);
  static const Color fogColor = Color.fromARGB(220, 10, 10, 15); // Subtle dark fog
}
