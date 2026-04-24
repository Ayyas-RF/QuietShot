import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/bot.dart';
import '../components/obstacle.dart';
import '../components/player.dart';
import '../utils/constants.dart';

class HudState {
  final int playerAmmo;
  final bool playerReloading;
  final int botAmmo;
  final bool botReloading;
  final int timeRemaining;
  final String winner;

  HudState({
    required this.playerAmmo,
    required this.botAmmo,
    required this.timeRemaining,
    this.playerReloading = false,
    this.botReloading = false,
    this.winner = '',
  });

  HudState copyWith({
    int? playerAmmo,
    bool? playerReloading,
    int? botAmmo,
    bool? botReloading,
    int? timeRemaining,
    String? winner,
  }) {
    return HudState(
      playerAmmo: playerAmmo ?? this.playerAmmo,
      playerReloading: playerReloading ?? this.playerReloading,
      botAmmo: botAmmo ?? this.botAmmo,
      botReloading: botReloading ?? this.botReloading,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      winner: winner ?? this.winner,
    );
  }
}

class QuietShotGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late Player player;
  late Bot bot;
  
  final ValueNotifier<HudState> hudNotifier = ValueNotifier(
    HudState(playerAmmo: GameConstants.ammoPerMag, botAmmo: GameConstants.ammoPerMag, timeRemaining: 120),
  );

  double _timer = 120.0;
  bool _isGameOver = false;

  @override
  Color backgroundColor() => const Color(0xFF1E1E1E); // Dark background

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Map boundaries
    add(Obstacle(position: Vector2(-50, -50), size: Vector2(size.x + 100, 50))); // Top
    add(Obstacle(position: Vector2(-50, size.y), size: Vector2(size.x + 100, 50))); // Bottom
    add(Obstacle(position: Vector2(-50, 0), size: Vector2(50, size.y))); // Left
    add(Obstacle(position: Vector2(size.x, 0), size: Vector2(50, size.y))); // Right

    // Some interior obstacles
    add(Obstacle(position: Vector2(200, 150), size: Vector2(50, 200)));
    add(Obstacle(position: Vector2(500, 300), size: Vector2(200, 50)));
    add(Obstacle(position: Vector2(100, 450), size: Vector2(150, 50)));

    // Subtle Fog Layer
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = GameConstants.fogColor,
        priority: 1, // Draw over obstacles (default priority 0)
      )
    );

    player = Player(position: Vector2(100, 100))..priority = 2;
    add(player);

    bot = Bot(position: Vector2(600, 400))..priority = 2;
    add(bot);
  }

  @override
  void update(double dt) {
    if (_isGameOver) return; // Stop logic if game over

    super.update(dt);
    
    _timer -= dt;
    if (_timer <= 0) {
      _timer = 0;
      onTimeOut();
    }
    
    if (hudNotifier.value.timeRemaining != _timer.ceil()) {
      hudNotifier.value = hudNotifier.value.copyWith(timeRemaining: _timer.ceil());
    }
  }

  void onPlayerDied() {
    _isGameOver = true;
    hudNotifier.value = hudNotifier.value.copyWith(winner: 'Bot Wins!');
    overlays.add('GameOver');
  }

  void onBotDied() {
    _isGameOver = true;
    hudNotifier.value = hudNotifier.value.copyWith(winner: 'Player Wins!');
    overlays.add('GameOver');
  }

  void onTimeOut() {
    _isGameOver = true;
    String winner;
    if (player.health > bot.health) {
      winner = 'Time Up! Player Wins by Health';
    } else if (bot.health > player.health) {
      winner = 'Time Up! Bot Wins by Health';
    } else {
      winner = 'Time Up! Draw!';
    }
    hudNotifier.value = hudNotifier.value.copyWith(winner: winner);
    overlays.add('GameOver');
  }
}
