import 'package:flutter/material.dart';
import '../game/quiet_shot_game.dart';

class GameOverOverlay extends StatelessWidget {
  final QuietShotGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HudState>(
       valueListenable: game.hudNotifier,
       builder: (context, state, child) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    state.winner,
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      // Simple way to restart the game is to remove the game engine and add it again,
                      // but since we don't have a state manager above GameWidget implemented,
                      // we can just reset game state here or reload the window for web/desktop.
                      // Alternatively, call a reset method on `game`.
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text('Restart to Main Menu', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          );
       }
    );
  }
}
