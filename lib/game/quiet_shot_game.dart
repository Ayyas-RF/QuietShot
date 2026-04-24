import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/enemy_bot.dart';
import '../components/obstacle.dart';
import '../components/player.dart';
import '../utils/constants.dart';
import 'map_generator.dart';

class HudState {
  final int playerAmmo;
  final int botAmmo;
  final int timeRemaining;
  final String? winner;
  final bool playerReloading;
  final bool botReloading;

  HudState({
    required this.playerAmmo,
    required this.botAmmo,
    required this.timeRemaining,
    this.winner,
    this.playerReloading = false,
    this.botReloading = false,
  });

  HudState copyWith({
    int? playerAmmo, 
    int? botAmmo, 
    int? timeRemaining, 
    String? winner,
    bool? playerReloading,
    bool? botReloading,
  }) {
    return HudState(
      playerAmmo: playerAmmo ?? this.playerAmmo,
      botAmmo: botAmmo ?? this.botAmmo,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      winner: winner ?? this.winner,
      playerReloading: playerReloading ?? this.playerReloading,
      botReloading: botReloading ?? this.botReloading,
    );
  }
}

class QuietShotGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late Player player;
  late EnemyBot bot;
  
  final ValueNotifier<HudState> hudNotifier = ValueNotifier(
    HudState(playerAmmo: GameConstants.ammoPerMag, botAmmo: GameConstants.ammoPerMag, timeRemaining: 120),
  );

  double _timer = 120.0;
  bool _isGameOver = false;
  bool _isMatchStarted = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Initially, we just show the menu. Match starts via startMatch().
  }

  void startMatch() {
    _isMatchStarted = true;
    _isGameOver = false;
    _timer = 120.0;
    
    // Clear everything
    removeAll(children);
    
    // Map boundaries
    add(Obstacle(position: Vector2(-50, -50), size: Vector2(size.x + 100, 50))); 
    add(Obstacle(position: Vector2(-50, size.y), size: Vector2(size.x + 100, 50))); 
    add(Obstacle(position: Vector2(-50, 0), size: Vector2(50, size.y))); 
    add(Obstacle(position: Vector2(size.x, 0), size: Vector2(50, size.y))); 

    // Procedural Level
    MapGenerator.generateLevel(this);

    // Subtle Fog Layer
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = GameConstants.fogColor,
        priority: 1, 
      )
    );

    player = Player(position: Vector2(100, 100))..priority = 2;
    add(player);

    bot = EnemyBot(position: Vector2(size.x - 100, size.y - 100))..priority = 2;
    add(bot);

    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    overlays.add('Hud');
  }

  @override
  void update(double dt) {
    if (!_isMatchStarted || _isGameOver) return;
    super.update(dt);
    
    _timer -= dt;
    if (_timer <= 0) {
      _timer = 0;
      onTimeOut();
    }
    
    if (hudNotifier.value.timeRemaining != _timer.ceil() || 
        hudNotifier.value.playerReloading != player.isReloading ||
        hudNotifier.value.botReloading != bot.isReloading) {
      hudNotifier.value = hudNotifier.value.copyWith(
        timeRemaining: _timer.ceil(),
        playerAmmo: player.ammo,
        botAmmo: bot.ammo,
        playerReloading: player.isReloading,
        botReloading: bot.isReloading,
      );
    }
  }

  void onPlayerDied() {
    _isGameOver = true;
    hudNotifier.value = hudNotifier.value.copyWith(winner: 'BOT WINS!');
    overlays.add('GameOver');
  }

  void onBotDied() {
    _isGameOver = true;
    hudNotifier.value = hudNotifier.value.copyWith(winner: 'PLAYER WINS!');
    overlays.add('GameOver');
  }

  void onTimeOut() {
    _isGameOver = true;
    String winner;
    if (player.health > bot.health) {
      winner = 'TIME UP! PLAYER WINS';
    } else if (bot.health > player.health) {
      winner = 'TIME UP! BOT WINS';
    } else {
      winner = 'DRAW!';
    }
    hudNotifier.value = hudNotifier.value.copyWith(winner: winner);
    overlays.add('GameOver');
  }

  void resetGame() {
    overlays.add('MainMenu');
    overlays.remove('GameOver');
    overlays.remove('Hud');
    _isMatchStarted = false;
  }
}
