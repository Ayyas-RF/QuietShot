import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/quiet_shot_game.dart';
import 'ui/hud_overlay.dart';
import 'ui/game_over_overlay.dart';
import 'ui/main_menu_overlay.dart';

void main() {
  runApp(const QuietShotApp());
}

class QuietShotApp extends StatelessWidget {
  const QuietShotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiet Shot',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: GameWidget<QuietShotGame>(
          game: QuietShotGame(),
          overlayBuilderMap: {
            'MainMenu': (context, QuietShotGame game) => MainMenuOverlay(game: game),
            'Hud': (context, game) => HudOverlay(game: game),
            'GameOver': (context, game) => GameOverOverlay(game: game),
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    );
  }
}
