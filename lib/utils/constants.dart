import 'package:flutter/material.dart';

class GameConstants {
  static const String playerSprite = 'player.png';
  static const String enemySprite = 'enemy.png';
  static const String crateSprite = 'crate.png';
  static const String serverUrl = 'ws://localhost:8080/ws';

  static const double playerSpeed = 200.0;
  static const double botSpeed = 100.0;
  static const double bulletSpeed = 700.0;
  
  static const double obstacleSize = 64.0;
  static const double playerSize = 32.0;

  static const double fovDistance = 350.0;
  static const double fovAngle = 1.2; // ~68 degrees total cone
  static const int rayCount = 60; // Accuracy of FOV

  static const int ammoPerMag = 10;
  static const double reloadTime = 2.0;
  static const double fireCooldown = 0.3;

  static const Color playerColor = Colors.blueAccent;
  static const Color botColor = Colors.redAccent;
  static const Color obstacleColor = Color.fromARGB(255, 60, 60, 60);
  static const Color fogColor = Color.fromARGB(220, 10, 10, 15); // Subtle dark fog
}
